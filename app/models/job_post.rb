class JobPost < ApplicationRecord
  include MeiliSearch::Rails

  has_one_attached :img

  enum provider: {
    gorails: 0,
    remoteok: 10,
    rubyjobboard: 20,
    rubyonremote: 30
  }

  meilisearch enqueue: :trigger_job do
    attribute :name, :company, :location, :created_at
    searchable_attributes %i[name company location]
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

  scope :for_index, -> { includes(img_attachment: :blob).order(posted_at: :desc, created_at: :desc) }

  validates :pid, :provider, :name, :url, presence: true

  def self.trigger_job(record, remove)
    JobPosts::SearchIndexJob.perform_async(record.id, remove)
  end
end
