class JobPosts::UploadImgJob < ApplicationJob
  queue_as :default

  def perform(job_post_id, refresh: false)
    job_post = JobPost.find(job_post_id)
    if job_post.img_url.blank?
      job_post.img.purge_later if refresh && job_post.img.attached?
      return
    end
    return if job_post.img.attached? && !refresh

    blob = Down.download(job_post.img_url, max_redirects: 5, open_timeout: 10)

    job_post.img.attach(
      io: blob,
      filename: blob.original_filename,
      content_type: blob.content_type
    )
  rescue Down::InvalidUrl, Down::NotFound
    job_post.update!(img_url: nil)
    job_post.img.purge_later if refresh && job_post.img.attached?
  end
end
