class Bookmark < ApplicationRecord
  belongs_to :job_post
   validates :user_id, presence: true
end
