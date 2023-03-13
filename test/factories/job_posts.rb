FactoryBot.define do
  factory :job_post do
    provider { JobPost.providers.keys.sample }
    sequence(:pid) { |i| "pid_#{i}" }
    sequence(:name) { |i| "Name #{i}" }
    sequence(:url) { |i| "https://jobs.com/#{i}" }
    sequence(:company) { |i| "Company #{i}" }

    trait :with_logo do
      after(:build) do |instance|
        instance.img.attach(
          io: Rails.root.join("test/fixtures/files/logo.jpeg").open,
          filename: "logo.jpeg"
        )
      end
    end
  end
end
