FactoryBot.define do
  factory :user, aliases: [:creator] do |_u|
  first_name    { Faker::Name.first_name }
  last_name     { Faker::Name.last_name }
  email         { Faker::Internet.email("#{first_name || Faker::Cat.name} #{last_name}", '', '.', '_') }
  password      { 'Abcd1234' }
  expires_at    2.days.from_now
  sign_in_count 2
  end
end
