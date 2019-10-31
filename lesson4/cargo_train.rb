# frozen_string_literal: true

require_relative 'train'

class CargoTrain < Train
  attr_reader :type

  def initialize(number)
    super(number)
    @type = 'Cargo'
  end
end
