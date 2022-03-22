class Api::V1::PersonsController < Api::V1::BaseController
  before_action :set_person, only: %i[show update destroy]

  def show
    respond_to do |format|
      format.json { render json: PersonSerializer.new(@person) }
    end
  end

  def index
    respond_to do |format|
      format.json {
        cache = ActiveSupport::Cache::MemoryStore.new
        @persons = cache.fetch(Person.cache_key) do
          PersonSerializer.new(
            if params[:last_hours].present? 
              Persons::RecentlyCreatedPersonsQuery.call(last_hours: params[:last_hours]) 
            else
              Person.all
            end
          ).serializable_hash.to_json
        end    

        render json: @persons
      }
    end
  end

  def create
    respond_to do |format|
      format.json {
        @person = Person.new(person_params)

        if @person.save
          render json: PersonSerializer.new(@person), status: :created
        else
          render json: ErrorSerializer.serialize(@person.errors), status: :unprocessable_entity
        end
      }
    end
  end

  def update
    respond_to do |format|
      format.json {
        if @person.update(person_params)
          render json: PersonSerializer.new(@person)
        else
          render json: ErrorSerializer.serialize(@person.errors), status: :unprocessable_entity
        end
      }
    end
  end

  def destroy
    respond_to do |format|
      format.json {
        render json: @person.destroy
      }
    end
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:name, :surname, :email, :age)
  end
end