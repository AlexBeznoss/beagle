namespace :logos do
  desc "Queue checks and re-download missing stored logos for visible jobs"
  task repair: :environment do
    JobPost.where(hidden: false).where.not(img_url: [nil, ""]).find_each do |post|
      JobPosts::UploadImgJob.perform_later(post.id)
    end
  end
end
