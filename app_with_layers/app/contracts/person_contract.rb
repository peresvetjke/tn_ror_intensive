class PersonContract < ApplicationContract
  # params do
  json do
    required(:surname).filled(:string)
    required(:email).filled(:string)
    required(:age).value(:integer)
  end

  rule(:email) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure('has invalid format')
    end
  end

  rule(:age) do
    key.failure('must be greater than 18') if value <= 18
  end
end

# contract = NewUserContract.new

# contract.call(email: 'jane@doe.org', age: '17')
# #<Dry::Validation::Result{:email=>"jane@doe.org", :age=>17} errors={:age=>["must be greater than 18"]}>
