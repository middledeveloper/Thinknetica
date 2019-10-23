require_relative 'train'
require_relative 'route'

class Station
  attr_accessor :name
  attr_accessor :trains

  def initialize(name)
    @name = name
    @trains = []
  end

  def add_train(train)
    self.trains.push(train)
  end

  def delete_train(train)
    self.trains.delete(train)
  end

  def train_repo()
    puts self.trains
  end
end
