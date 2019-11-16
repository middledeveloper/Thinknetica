# frozen_string_literal: true

require_relative 'train'
require_relative 'route'
require_relative 'instance_counter'

class Station
  include InstanceCounter

  attr_reader :name, :trains
  @all = []

  def initialize(name)
    @name = name
    @trains = []
    validate!
    self.class.all.push(self)
    register_instance
  end

  class << self
    attr_accessor :all
  end

  def add_train(train)
    trains.push(train)
  end

  def delete_train(train)
    trains.delete(train)
  end

  def trains_on_station
    trains.each { |t| yield(t) } if block_given?
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  private

  def validate!
    if name.empty?
      raise StandardError, 'Наименование станции не может быть пустым!'
    end
  end
end
