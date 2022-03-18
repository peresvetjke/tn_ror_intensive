module Loggable
  FILE_NAME = "service.log"

  def call
    log("Service is starting")
    super
    log("The end")
  end

  private

  def log(text)
    File.open(FILE_NAME, "a") {|f| f.write("#{Time.now}: #{text}\n") }
  end
end

class MyService
  prepend Loggable

  def call
    sleep(3)
  end
end


# Напишите пример использования подключения модуля с помощью `prepend`. Пример должен быть рабочим и выполнять определённую задачу (цель) 