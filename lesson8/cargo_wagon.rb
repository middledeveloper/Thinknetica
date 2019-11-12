# frozen_string_literal: true

require_relative 'wagon'

class CargoWagon < Wagon
  attr_reader :capacity, :taken_capacity

  def initialize(manufacturer, capacity)
    @type = 'Cargo'
    super
  end

  def take_capacity(value)
    if value >= 0 && capacity >= (taken_capacity + value)
      self.taken_capacity += value
    end
  end

  private

  attr_writer :taken_capacity
end
