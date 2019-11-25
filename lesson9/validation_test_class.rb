# frozen_string_literal: true

require_relative 'validation'

class ValidationTestClass
  include Validation

  attr_accessor :name, :attr_validations

  validate :name, :presence
  validate :name, :format, /[A-Za-z]{3,15}.[A-Za-z]{3,15}/
  validate :name, :type, String

  validate :author, :presence
  validate :author, :format, /[A-Za-z]{3,20}.[A-Za-z]{3,20}/
  validate :author, :type, String

  def initialize(title, author)
    @name = title
    @author = author
    validate!
  end
end

ds = ValidationTestClass.new('Death Stranding', 'Hideo Kojima')
# puts ds.valid?
