# frozen_string_literal: true

require_relative 'train'
require_relative 'route'

class Station
  attr_reader :name, :trains

  def initialize(name)
    @name = name
    @trains = []
  end

  def add_train(train)
    trains.push(train)
  end

  def delete_train(train)
    trains.delete(train)
  end

  def train_repo
    trains
  end
end
