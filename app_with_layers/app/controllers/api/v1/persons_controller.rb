class Api::V1::PersonsController < Api::V1::BaseController
  def show
    respond_to do |format|
      format.json {
        render json: Person.find(params[:id])
      }
    end
  end

  def index
    respond_to do |format|
      format.json {
        if params[:last_hours]
          render json: Persons::RecentlyCreatedPersonsQuery.call(last_hours: params[:last_hours])
        else
          render json: Person.all
        end
      }
    end
  end

  def create
    respond_to do |format|
      format.json {
        @person = Person.new(person_params)
        validation = PersonContract.new.call(person_params.to_h)

        if validation.success?
          @person.save
          render json: @person
        else
          render json: validation.errors.to_h
        end
      }
    end
  end

  def update
    respond_to do |format|
      format.json {
        @person = Person.find(params[:id])
        validation = PersonContract.new.call(@person.as_json.merge(person_params.to_h))

        if validation.success?
          @person.update(person_params)
          render json: @person
        else
          render json: validation.errors.to_h
        end
      }
    end
  end

  def destroy
    respond_to do |format|
      format.json {
        render json: Person.find(params[:id]).destroy
      }
    end
  end

  private

  def person_params
    params.require(:person).permit(:name, :surname, :email, :age)
  end
end