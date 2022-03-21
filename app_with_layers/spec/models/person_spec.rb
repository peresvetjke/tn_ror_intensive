require 'rails_helper'

RSpec.describe Person, type: :model do

  describe "validations" do
    it "presence of name" do
      expect(build(:person, name: '')).to be_invalid
    end

    it "presence of surname" do
      expect(build(:person, surname: '')).to be_invalid
    end

    it "presence of email" do
      expect(build(:person, email: '')).to be_invalid
    end

    describe "age" do
      it "presence" do
        expect(build(:person, age: nil)).to be_invalid
      end
      
      it "greater than 0" do
        expect(build(:person, age: 0)).to be_invalid
      end
    end
    
    it "creates a valid record" do
      expect(build(:person)).to be_valid
    end
  end
end