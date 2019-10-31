# frozen_string_literal: true

require_relative 'wagon'

class CargoWagon < Wagon
  def initialize
    super('Cargo')
  end
end
