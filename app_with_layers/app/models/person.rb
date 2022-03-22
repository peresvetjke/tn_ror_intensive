class Person < ApplicationRecord
  validates_with ContractValidator
  
  def self.cache_key
    {
      serializer: 'persons',
      stat_record: Person.maximum(:updated_at)
    }
  end
end
