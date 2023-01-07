class JobPost < ApplicationRecord
  has_one_attached :img

  enum provider: {
    gorails: 0,
    remoteok: 10,
    rubyjobboard: 20,
    rubyonremote: 30
  }

  validates :pid, :provider, :name, :url, presence: true
end
