class JobPost < ApplicationRecord
  has_one_attached :img
  has_many :legacy_bookmarks, dependent: :delete_all

  enum :provider, {
    gorails: 0,
    remoteok: 10,
    rubyjobboard: 20,
    rubyonremote: 30,
    startupjobs: 40,
    weworkremotely: 50
  }

  include Litesearch::Model

  def self.configure_search_index
    litesearch do |schema|
      schema.field :name
      schema.field :company
      schema.field :location
    end
  end

  configure_search_index

  def self.search(term)
    terms = term.to_s.split.map { |word| %("#{word.gsub('"', '""')}") }.join(" ")
    return none if terms.empty?

    configure_search_index unless get_connection.get_first_value("SELECT name FROM sqlite_master WHERE name = ?", index_name)

    select("#{table_name}.*", "-#{index_name}.rank AS search_rank")
      .joins("INNER JOIN #{index_name} ON #{table_name}.rowid = #{index_name}.rowid")
      .where("#{index_name} MATCH ?", terms)
      .order(Arel::Table.new(index_name)[:rank].asc)
  end

  scope :for_index, -> { where(hidden: false).includes(img_attachment: :blob).order(created_at: :desc) }
  scope :for_cleanup, -> { where(created_at: ..3.months.ago.beginning_of_day) }

  validates :pid, :provider, :name, :url, presence: true

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
