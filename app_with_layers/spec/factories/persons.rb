FactoryBot.define do
  factory :person do
    name    { generate(:name) }
    surname { generate(:surname) }
    email   { generate(:email) }
    age     { 20 }
  end
end