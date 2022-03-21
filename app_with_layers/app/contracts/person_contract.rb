class PersonContract < ApplicationContract
  json do
    required(:name).filled(:string)
    required(:surname).filled(:string)
    required(:email).filled(:string)
    required(:age).filled(gt?: 0)
  end

  rule(:email) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure('has invalid format')
    end
  end
end