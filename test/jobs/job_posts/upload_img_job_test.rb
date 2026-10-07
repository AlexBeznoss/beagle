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

  test "re-downloads an attached logo whose storage object is missing" do
    post = FactoryBot.create(:job_post, img_url: "https://example.com/logo.jpg")
    attach_logo(post)
    post.img.blob.service.delete(post.img.blob.key)
    download = StringIO.new(file_fixture("logo.jpeg").binread)
    download.define_singleton_method(:original_filename) { "repaired.jpg" }
    download.define_singleton_method(:content_type) { "image/jpeg" }

    Down.stub(:download, download) { JobPosts::UploadImgJob.perform_now(post.id) }

    assert_equal "repaired.jpg", post.reload.img.filename.to_s
    assert post.img.blob.service.exist?(post.img.blob.key)
    assert download.closed?
  end

  test "an upload failure preserves the previous working attachment" do
    post = FactoryBot.create(:job_post, img_url: "https://example.com/logo.jpg")
    attach_logo(post)
    original_key = post.img.blob.key
    download = StringIO.new(file_fixture("logo.jpeg").binread)
    download.define_singleton_method(:original_filename) { "replacement.jpg" }
    download.define_singleton_method(:content_type) { "image/jpeg" }

    Down.stub(:download, download) do
      post.img.blob.service.stub(:upload, ->(*) { raise IOError, "Upload failed" }) do
        assert_raises(IOError) { JobPosts::UploadImgJob.perform_now(post.id, refresh: true) }
      end
    end

    assert_equal original_key, post.reload.img.blob.key
    assert post.img.blob.service.exist?(original_key)
    assert download.closed?
  end

  private

  def attach_logo(post)
    post.img.attach(io: StringIO.new(file_fixture("logo.jpeg").binread), filename: "old.jpg", content_type: "image/jpeg")
  end
end
