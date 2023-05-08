class JobPost < ApplicationRecord
  include MeiliSearch::Rails

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

  meilisearch enqueue: :trigger_job do
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

  scope :for_index, -> { includes(img_attachment: :blob).order(created_at: :desc) }
  scope :with_bookmark, ->(user_id) {
    join = <<~SQL.squish
      LEFT JOIN "bookmarks"
      ON "bookmarks"."job_post_id" = "job_posts"."id"
      AND "bookmarks"."user_id" = '#{user_id}'
    SQL

    joins(join).select('"job_posts".*, "bookmarks"."id" AS "bookmark_id"')
  }

  validates :pid, :provider, :name, :url, presence: true

  def self.trigger_job(record, remove)
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
