class JobPosts::CleanupJob < ApplicationJob
  queue_as :default

  before_perform do
    Rails.application
      .credentials
      .dig(:honeybadger, :checkins, :start_job_posts_cleanup)
      .then { |key| Honeybadger.check_in(key) }
  end

  def perform
    JobPost.for_cleanup.each(&:destroy!)
  end
end
