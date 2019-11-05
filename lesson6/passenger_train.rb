# frozen_string_literal: true

require_relative 'train'

class PassengerTrain < Train
  attr_reader :type

  def initialize
    @type = 'Passenger'
    super
  end
end
