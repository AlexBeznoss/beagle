class JobPost < ApplicationRecord
  include MeiliSearch::Rails
  include PgSearch::Model
  attribute :bookmark_id

  has_one_attached :img
  has_many :bookmarks, dependent: :destroy

  enum provider: {
    gorails: 0,
    remoteok: 10,
    rubyjobboard: 20,
    rubyonremote: 30,
    startupjobs: 40,
    weworkremotely: 50
  }

  pg_search_scope :search_local, against: {
    name: "A",
    company: "B",
    location: "C"
  }, using: {tsearch: {prefix: true}}

  meilisearch unless: :hidden?, enqueue: :trigger_mailsearch_job do
    attribute :name, :company, :location, :provider_label, :created_at
    searchable_attributes %i[name company location provider_label]
    ranking_rules [
      "proximity",
      "typo",
      "words",
      "attribute",
      "sort",
      "exactness",
      "created_at:desc"
    ]
  end

  scope :for_index, -> { where(hidden: false).includes(img_attachment: :blob).order(created_at: :desc) }
  scope :with_bookmark_id, ->(user_id) {
    bookmarks = BabySqueel[:bookmarks]

    joining do |jp|
      bookmarks.outer.on(
        (bookmarks.job_post_id == jp.id) &
        (bookmarks.user_id == user_id)
      )
    end.select('"job_posts".*, "bookmarks"."id" AS "bookmark_id"')
  }
  scope :for_bookmarks_index, ->(user_id) {
    bookmarks = BabySqueel[:bookmarks]

    joining do |jp|
      bookmarks.on(
        (bookmarks.job_post_id == jp.id) &
        (bookmarks.user_id == user_id)
      )
    end.select('"job_posts".*, "bookmarks"."id" AS "bookmark_id"')
      .for_index
      .reorder('"bookmarks"."created_at" DESC, "job_posts"."created_at" DESC')
  }
  scope :for_cleanup, -> { where.has { |jp| jp.created_at <= 3.months.ago.beginning_of_day } }

  validates :pid, :provider, :name, :url, presence: true

  def self.trigger_mailsearch_job(record, remove)
    JobPosts::SearchIndexJob.perform_async(record.id, remove)
  end

  def provider_label
    {
      "remoteok" => "RemoteOK",
      "gorails" => "GoRails",
      "rubyjobboard" => "RubyJobBoard",
      "rubyonremote" => "RubyOnRemote",
      "startupjobs" => "StartupJobs",
      "weworkremotely" => "WeWorkRemotely"
    }[provider]
  end
end
