FactoryBot.define do
  factory :event do |_e|
    association     :user
    title           { Faker::Markdown.headers }
    description     { Faker::Markdown.emphasis }
    start_date      { 2.days.ago }
    end_date        { 2.days.from_now }
    venue           { Faker::Name.name }
    guest_list      { "#{Faker::Internet.email}, #{Faker::Internet.email}" }
    google_event_id { Faker::String.random(10) }
  end
end
