FactoryBot.define do
  factory :bookmark do
    association :job_post
    sequence(:user_id) { |i| "clerk_user_#{i}" }
  end
end
