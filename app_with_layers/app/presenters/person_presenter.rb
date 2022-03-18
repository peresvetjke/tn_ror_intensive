# http://railscasts.com/episodes/287-presenters-from-scratch

class PersonPresenter < BasePresenter
  presents :person

  def full_name
    if person.name.present? && person.surname.present?
      "#{person.name} #{person.surname}"
    elsif person.surname.present?
      person.surname
    else
      handle_none nil
    end
  end

  def errors
    validation = PersonContract.new.call(person.as_json.to_h)
    validation.success? ? nil : h.content_tag(:span, validation.errors.to_h)
  end

private

  def handle_none(value)
    if value.present?
      yield
    else
      h.content_tag :span, "Not available", class: "none"
    end
  end
end

