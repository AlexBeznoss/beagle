module JobPosts
  class SearchIndexJob
    include Sidekiq::Job

    def perform(job_post_id, remove)
      if remove
        JobPost.index.delete_document(job_post_id)
      else
        JobPost.find(job_post_id).index!
      end
    end
  end
end
