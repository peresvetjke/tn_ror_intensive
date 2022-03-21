FactoryBot.define do
  sequence(:name)     { |n| "name_#{n}" }
  sequence(:surname)  { |n| "surname_#{n}" }
  sequence(:email)    { |n| "person#{n}@example.com" }
end