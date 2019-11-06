# frozen_string_literal: true

require_relative 'manufacturer'

class Wagon
  include Manufacturer

  attr_reader :type

  def initialize(manufacturer)
    @manufacturer = manufacturer
    valid?
  end

  def valid?
    validate!
    true
  end

  private

  def validate!
    types = %w[Cargo Passenger]
    raise StandardError, 'Неизвестный тип вагона!' unless types.include?(type)
    if manufacturer.empty?
      raise StandardError, 'Некорректное наименонивание производителя!'
    end
  end
end
