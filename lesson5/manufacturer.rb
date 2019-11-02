# frozen_string_literal: true

module Manufacturer
  attr_reader :name

  def set_manufacturer_name(name)
    @name = name
  end

  def get_manufacturer_name
    name
  end

  private

  attr_writer :name
end
