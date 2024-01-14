class JobPosts::UploadImgJob < ApplicationJob
  queue_as :default

  def perform(job_post_id)
    job_post = JobPost.find(job_post_id)
    return if job_post.img_url.blank? || job_post.img.attached?

    blob = Down.download(job_post.img_url, max_redirects: 5, open_timeout: 10)

    job_post.img.attach(
      io: blob,
      filename: blob.original_filename,
      content_type: blob.content_type
    )
  rescue Down::InvalidUrl, Down::NotFound
    job_post.update!(img_url: nil)
  end
end
