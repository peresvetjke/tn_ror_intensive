class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :surname, :email, :age
end
