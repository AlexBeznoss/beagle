FactoryBot.define do
  factory :job_post do
    provider { JobPost.providers.keys.sample }
    sequence(:pid) { |i| "pid_#{i}" }
    sequence(:name) { |i| "Name #{i}" }
    sequence(:url) { |i| "https://jobs.com/#{i}" }
    sequence(:company) { |i| "Company #{i}" }
  end
end
