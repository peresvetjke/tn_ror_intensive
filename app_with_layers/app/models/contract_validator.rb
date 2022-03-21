class ContractValidator < ActiveModel::Validator
  def validate(record)
    contract = "#{record.class}Contract".constantize.new
    validation = contract.call(record.as_json.to_h)
    
    validation.errors.each do |error_message|
      field = error_message.path.first || :base
      record.errors.add field, error_message.text
    end
  end
end