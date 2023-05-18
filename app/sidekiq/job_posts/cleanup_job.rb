module JobPosts
  class CleanupJob
    include Sidekiq::Job
    include SidekiqIteration::Iteration

    def on_start
      Rails.application
        .credentials
        .dig(:honeybadger, :checkins, :start_job_posts_cleanup)
        .then { |key| Honeybadger.check_in(key) }
    end

    def build_enumerator(cursor:)
      active_record_records_enumerator(
        JobPost.for_cleanup,
        cursor: cursor,
        batch_size: 5
      )
    end

    def each_iteration(job_post)
      job_post.destroy!
    end
  end
end
