FactoryBot.define do
  factory :bookmark do
    job_post
    sequence(:user_id) { |i| "clerk_user_#{i}" }
  end
end
