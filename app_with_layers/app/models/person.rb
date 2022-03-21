class Person < ApplicationRecord
  validates_with ContractValidator
  
end
