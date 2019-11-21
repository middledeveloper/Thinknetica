# frozen_string_literal: true

require_relative 'validation'

class ValidationTestClass
  include Validation

  attr_accessor :name, :author

  def initialize(title, author)
    @title = title
    @author = author
    params = { title: title, author: author }
    params.each do |param|
      self.class.validate(param, :presence)
      self.class.validate(param, :format, /A-Z{0,3}/)
      self.class.validate(param, :type, String)
    end
  end
end

ds = ValidationTestClass.new('Death Stranding', 'Hideo Kojima')
puts ds.inspect
