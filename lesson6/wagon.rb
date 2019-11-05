# frozen_string_literal: true

require_relative 'manufacturer'

class Wagon
  include Manufacturer

  attr_reader :type

  def initialize(type)
    @type = type
  end

  def valid?
    validate!
    true
  end

  private

  def validate!; end
end
