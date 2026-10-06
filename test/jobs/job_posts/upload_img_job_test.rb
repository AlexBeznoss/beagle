require "test_helper"

class JobPosts::UploadImgJobTest < ActiveJob::TestCase
  test "replaces an attached image when the source logo changes" do
    post = FactoryBot.create(:job_post, img_url: "https://example.com/new.jpg")
    attach_logo(post)
    blob = StringIO.new(file_fixture("logo.jpeg").binread)
    blob.define_singleton_method(:original_filename) { "new.jpg" }
    blob.define_singleton_method(:content_type) { "image/jpeg" }
    Down.stub(:download, blob) { JobPosts::UploadImgJob.perform_now(post.id, refresh: true) }
    assert_equal "new.jpg", post.reload.img.filename.to_s
  end

  test "removes an attached logo when the source clears it" do
    post = FactoryBot.create(:job_post, img_url: nil)
    attach_logo(post)
    JobPosts::UploadImgJob.perform_now(post.id, refresh: true)
    assert_not post.reload.img.attached?
  end

  test "ordinary repeated image jobs keep existing attachments" do
    post = FactoryBot.create(:job_post, img_url: "https://example.com/logo.jpg")
    attach_logo(post)
    Down.stub(:download, ->(*) { raise "Unexpected download" }) { JobPosts::UploadImgJob.perform_now(post.id) }
    assert_equal "old.jpg", post.reload.img.filename.to_s
  end

  private

  def attach_logo(post)
    post.img.attach(io: StringIO.new(file_fixture("logo.jpeg").binread), filename: "old.jpg", content_type: "image/jpeg")
  end
end
