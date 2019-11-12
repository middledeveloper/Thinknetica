# frozen_string_literal: true

require_relative 'wagon'

class PassengerWagon < Wagon
  attr_reader :capacity, :taken_capacity

  def initialize(manufacturer, capacity)
    @type = 'Passenger'
    super
  end

  def take_capacity
    self.taken_capacity += 1 if capacity >= (taken_capacity + 1)
  end

  private

  attr_writer :taken_capacity
end
