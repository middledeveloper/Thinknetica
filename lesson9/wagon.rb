# frozen_string_literal: true

require_relative 'manufacturer'
require_relative 'accessors'

class Wagon
  include Accessors
  include Manufacturer

  attr_reader :number, :type

  def initialize(manufacturer, capacity)
    @number = rand(1000...9000).to_s
    @manufacturer = manufacturer
    @capacity = capacity
    @taken_capacity = 0
    validate!
  end

  def free_capacity
    capacity - taken_capacity
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  private

  def validate!
    types = %w[Cargo Passenger]
    raise StandardError, 'Неизвестный тип вагона!' unless types.include?(type)
    if manufacturer.empty?
      raise StandardError, 'Некорректное наименование производителя!'
    end
    if capacity.negative?
      raise StandardError, 'Некорректное значение вместительности!'
    end
  end
end
