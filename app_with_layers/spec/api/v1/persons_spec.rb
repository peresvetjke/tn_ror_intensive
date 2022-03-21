require "rails_helper"

describe "Persons API", type: :request do
  let(:headers)         { { "ACCEPT"       => "application/json" } }
  let!(:person)         { create(:person) }
  let(:person_response) { json["data"] }
  let(:errors_response) { json["errors"] }

  describe "GET /api/v1/persons" do
    let(:method)              { "get" }
    let!(:persons)            { create_list(:person, 5) }
    let(:persons_response)    { json["data"] }
    let(:path)                { "/api/v1/persons" }
    
    subject { do_request("get", path, params: params, headers: headers) }
    
    context "no params" do
      let(:params) {{ }}

      before { subject }

      it "returns 200 status" do
        expect(response.status).to eq 200
      end

      it "returns all records" do
        expect(persons_response.count).to eq Person.count
      end

      it "returns all neccessary fields" do
        %w[name surname email age created_at updated_at].each do |attr|
          expect(persons_response.last['attributes'][attr]).to eq persons.last.send(attr).as_json
        end
      end
    end

    context "querying last hours records" do
      let(:params) { { last_hours: 5 } }

      before { 
        travel_to Time.zone.local(2004, 11, 24, 01, 04, 44)
        create_list(:person, 5)
        travel_back
        subject
      }

      it "returns 200 status" do
        expect(response.status).to eq 200
      end

      it "returns the recent records" do
        expect(persons_response.count).to eq Person.where('created_at > ?', 5.hours.ago).count
      end
    end
  end

  describe "GET /api/v1/person/:id" do
    let(:method)    { "get" }
    let!(:person)   { create(:person) }
    let(:path)      { "/api/v1/persons/#{person.id}" }

    before { do_request("get", path, params: { }, headers: headers) }

    it "returns 200 status" do
      expect(response.status).to eq 200
    end

    it "returns all neccessary fields" do
      %w[name surname email age created_at updated_at].each do |attr|
        expect(person_response['attributes'][attr]).to eq person.send(attr).as_json
      end
    end
  end

  describe "POST /api/v1/persons" do
    let(:method)    { "post" }
    let(:path)      { "/api/v1/persons" }

    context 'with valid params' do
      before { do_request(method, 
                          path, 
                          params: { person: attributes_for(:person) }, 
                          headers: headers
                         ) 
              }

      it "return status 'created'" do
        expect(response.status).to eq 201
      end

      it "returns all neccessary fields of created person" do
        %w[name surname email age created_at updated_at].each do |attr|
          expect(person_response['attributes'][attr]).to eq assigns(:person).send(attr).as_json
        end
      end
    end

    context 'with invalid params' do
      before { do_request(method, 
                          path, 
                          params: { person: attributes_for(:person, name: "") }, 
                          headers: headers
                         ) 
              }

      it "return status 'unprocessable'" do
        expect(response.status).to eq 422
      end

      it "returns errors messages" do
        expect(json["errors"].first['message']).to eq "Name must be filled"
      end
    end
  end
  
  describe "PATCH /api/v1/persons/:id" do
    let(:method)    { "patch" }
    let(:path)      { "/api/v1/persons/#{person.id}" }

    context 'with valid params' do
      before { do_request(method, path, params: { id: person, person: attributes_for(:person, surname: "Corrected") }, headers: headers) }

      it "return successfull status" do
        expect(response).to be_successful
      end

      it "returns all neccessary fields of updated person" do
        expect(person_response['attributes']['surname']).to eq assigns(:person).reload.surname
        %w[name surname email age created_at updated_at].each do |attr|
          expect(person_response['attributes'][attr]).to eq assigns(:person).send(attr).as_json
        end
      end
    end

    context 'with invalid params' do
      before { do_request(method, path, params: { id: person, person: attributes_for(:person, surname: "") }, headers: headers) }

      it "return status 'unprocessable'" do
        expect(response.status).to eq 422
      end

      it "returns errors messages" do
        expect(json["errors"].first['message']).to eq "Surname must be filled"
      end
    end
  end

  describe "DELETE /api/v1/persons/:id" do
    let(:method)    { "delete" }
    let(:path)      { "/api/v1/persons/#{person.id}" }

    before { do_request(method, path, params: { id: person }, headers: headers) }

    it "return successfull status" do
      expect(response).to be_successful
    end

    it "deletes record" do
      expect(assigns(:person).persisted?).to be_falsey
    end
  end
end