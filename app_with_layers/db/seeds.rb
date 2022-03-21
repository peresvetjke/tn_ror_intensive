# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


5.times do |i|
  Person.create(
    name: "name_#{i}",
    surname: "surname_#{i}",
    email: "name_#{i}.surname_#{i}@example.com",
    age: (15..40).to_a.sample
  )
end