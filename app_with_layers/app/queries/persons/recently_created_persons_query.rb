module Persons
  class RecentlyCreatedPersonsQuery
    def self.call(relation: Person.all, last_hours:)
      relation.where('created_at > ?', last_hours.to_i.hours.ago)
    end
  end
end