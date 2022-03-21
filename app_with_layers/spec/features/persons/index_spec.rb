require "rails_helper"

feature 'User can view all persons list', %q{
  In order to find the one he interested in
} do

  scenario "without records" do
    visit persons_path
    expect(page).to have_text("No records yet")
  end

  feature "with few records" do    
    let!(:persons) { create_list(:person, 5) }
    let(:person)   { persons.last }

    background { visit persons_path }

    scenario "shows all person records" do
      save_and_open_page
      expect(page).to have_selector('.person', count: 5)
    end

    scenario "shows name and surname" do
      expect(page).to have_content(person.name)
      expect(page).to have_content(person.surname)
    end
  end
end