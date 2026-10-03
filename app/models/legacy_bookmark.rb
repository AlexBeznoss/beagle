# Retained only to clean up the historical foreign key when a job is deleted.
class LegacyBookmark < ApplicationRecord
  self.table_name = "bookmarks"

  belongs_to :job_post
end
