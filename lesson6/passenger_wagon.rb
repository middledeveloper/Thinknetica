# frozen_string_literal: true

require_relative 'wagon'

class PassengerWagon < Wagon
  def initialize(manufacturer)
    @type = 'Passenger'
    super
  end
end
