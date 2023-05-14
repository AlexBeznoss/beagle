require "test_helper"

class JobPostTest < ActiveSupport::TestCase
  describe ".with_bookmark_id" do
    test "returns job posts with bookmark_id if has on" do
      user_id = "fake_user_id1"
      job_post1 = FactoryBot.create(:job_post)
      job_post2 = FactoryBot.create(:job_post)
      bookmark = FactoryBot.create(:bookmark, user_id: user_id, job_post: job_post2)
      job_post3 = FactoryBot.create(:job_post)
      FactoryBot.create(:bookmark, job_post: job_post3)
      expected_result = [
        [job_post1.id, nil],
        [job_post2.id, bookmark.id],
        [job_post3.id, nil]
      ].sort

      result = JobPost
        .with_bookmark_id(user_id)
        .map { |jp| [jp.id, jp.bookmark_id] }
        .sort

      assert_equal expected_result, result
    end
  end

  describe ".for_bookmarks_index" do
    test "returns job_posts with bookmark_id only according to bookmark creation date" do
      user_id = "fake_user_id1"
      FactoryBot.create(:job_post)
      job_post2 = FactoryBot.create(:job_post)
      bookmark1 = FactoryBot.create(:bookmark, user_id: user_id, job_post: job_post2)
      FactoryBot.create(:bookmark, job_post: job_post2)
      job_post3 = FactoryBot.create(:job_post)
      bookmark2 = FactoryBot.create(:bookmark, user_id: user_id, job_post: job_post3)
      job_post4 = FactoryBot.create(:job_post)
      FactoryBot.create(:bookmark, job_post: job_post4)
      expected_result = [
        [job_post3.id, bookmark2.id],
        [job_post2.id, bookmark1.id]
      ]

      result = JobPost
        .for_bookmarks_index(user_id)
        .map { |jp| [jp.id, jp.bookmark_id] }

      assert_equal expected_result, result
    end
  end
end
