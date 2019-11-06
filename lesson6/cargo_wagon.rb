# frozen_string_literal: true

require_relative 'wagon'

class CargoWagon < Wagon
  def initialize(manufacturer)
    @type = 'Cargo'
    super
  end
end
