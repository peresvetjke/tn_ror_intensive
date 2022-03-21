class PersonSerializer
  include JSONAPI::Serializer
  attributes :name, :surname, :email, :age, :created_at, :updated_at
end
