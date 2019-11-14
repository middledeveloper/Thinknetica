# frozen_string_literal: true

require_relative 'route'
require_relative 'station'
require_relative 'train'
require_relative 'cargo_train'
require_relative 'passenger_train'
require_relative 'wagon'
require_relative 'cargo_wagon'
require_relative 'passenger_wagon'

class UI
  attr_reader :station_repo, :route_repo, :train_repo, :wagon_repo, :procs

  def initialize
    @station_repo = []
    @route_repo = []
    @train_repo = []
    @wagon_repo = []
    @procs = {
      station: proc { |train|
        puts "#{train.number}', #{train.type}, #{train.wagons.count}"
      },
      train: proc { |wagon|
        puts "#{wagon.number}, #{wagon.type}, #{wagon.free_capacity}"
      }
    }
  end

  def work
    loop do
      show_main_menu
      choice = get_choice(gets.chomp)
      case choice
      when 1
        create_station
      when 2
        create_train
      when 3
        create_route
      when 4
        set_route
      when 5
        add_wagon
      when 6
        remove_wagon
      when 7
        move_train
      when 8
        station_monitor
      when 9
        proc_monitor
      when 10
        take_capacity
      end
    end
  end

  private

  def show_main_menu
    puts '1. Создать станцию'
    puts '2. Создать поезд'
    puts '3. Создать маршрут'
    puts '4. Назначить маршрут поезду'
    puts '5. Добавить вагон к поезду'
    puts '6. Отцепить вагон от поезда'
    puts '7. Перемещение поезда по маршруту'
    puts '8. Просмотр станций и поездов'
    puts '9. Просмотр станций, поездов и вагонов (Proc)'
    puts '10. Занять место в вагоне'
    puts 'Q => ВЫХОД'
    print 'Введите номер необходимого действия: '
  end

  def create_station
    print 'Введите наименование станции: '
    station = Station.new(gets.chomp)
    station_repo.push(station)
  rescue StandardError => e
    print_error(e)
    retry
  end

  def create_train
    print "Укажите тип поезда 1 'Пассажирский', или 2 'Грузовой': "
    type = get_choice(gets.chomp)
    print 'Укажите номер поезда: '
    number = gets.chomp
    print 'Укажите скорость поезда: '
    speed = get_choice(gets.chomp)
    train = if type == 2
              CargoTrain.new(number, speed)
            else
              PassengerTrain.new(number, speed)
            end
    train_repo.push(train)
    puts "Поезд #{train.number} #{train.type} создан, скорость #{train.speed}!"
  rescue StandardError => e
    print_error(e)
    retry
  end

  def create_route
    if station_repo.count < 2
      puts 'Недостаточно станций для создания маршрута'
    else
      print_station_list
      print 'Необходимо указать начальную станцию: '
      first_station = station_repo[get_choice(gets.chomp) - 1]
      print 'Необходимо указать конечную станцию: '
      last_station = station_repo[get_choice(gets.chomp) - 1]

      route = Route.new(first_station, last_station)
      route_repo.push(route)
    end
  rescue StandardError => e
    print_error(e)
    retry
  end

  def set_route
    if train_repo.count.zero?
      puts 'Не создано ни одного поезда'
    elsif route_repo.count.zero?
      puts 'Не создано ни одного маршрута'
    else
      print_train_list
      train_add_route = train_repo[get_choice(gets.chomp) - 1]
      route_repo.each do |route|
        puts "Маршрут #{route_repo.index(route) + 1}."
      end

      print 'Укажите маршрут для добавления: '
      train_add_route.bind_route(route_repo[get_choice(gets.chomp) - 1])
    end
  end

  def add_wagon
    print_train_list
    train = train_repo[get_choice(gets.chomp) - 1]
    print "Укажите 1 'Создать вагон', или 2 'Использовать существующий': "
    choice = get_choice(gets.chomp)

    if choice == 1
      wagon = make_new_wagon(train.type)
    elsif choice == 2
      print_unused_wagon_list
      wagon = wagon_repo[get_choice(gets.chomp) - 1]
    end

    train.add_wagon(wagon)
    puts "Вагон #{wagon.type} (#{wagon.manufacturer}) добавлен к поезду " \
         "#{train.number} (вагонов в составе: #{train.wagons.count})!"
  rescue StandardError => e
    print_error(e)
    retry
  end

  def remove_wagon
    train_repo.each do |train|
      print_train_info(train) if train.wagons.count.positive?
    end
    print 'Укажите от какого поезда следует отцепить вагон: '
    train = train_repo[get_choice(gets.chomp) - 1]
    train.remove_wagon(train.wagons.last)
    puts "Вагон поезда #{train.number} отцеплен"
  rescue StandardError => e
    print_error(e)
    retry
  end

  def move_train
    print_train_list
    train = train_repo[get_choice(gets.chomp) - 1]
    print "Укажите '1' для движения вперед, или '2' для движения назад': "
    direction = get_choice(gets.chomp)

    if direction == 1
      move_forward(train)
    elsif direction == 2
      move_backward(train)
    end
  end

  def move_forward(train)
    if train.station != train.route.stations.last
      train.move_forward
    else
      puts 'Поезд на конечной станции'
    end
  end

  def move_backward(train)
    if train.station != train.route.stations.first
      train.move_backward
    else
      puts 'Поезд на начальной станции'
    end
  end

  def station_monitor
    station_repo.each do |station|
      puts "Количество поездов на станции '#{station.name}':  " \
           "#{station.trains.count}"

      unless station.trains.empty?
        station.trains.each { |train| print_train_info(train) }
      end
    end
  end

  def proc_monitor
    station_repo.each do |station|
      if !station.trains.empty?
        puts "На станции #{station.name} поездов: #{station.trains.count}"
        station.trains_on_station(&procs[:station])
        station.trains.each { |train| train.wagons_in_train(&procs[:train]) }
      else
        puts "На станции #{station.name} поездов нет"
      end
    end
  end

  def take_capacity
    print_wagon_list
    wagon = wagon_repo[get_choice(gets.chomp) - 1]
    if wagon.type == 'Passenger'
      wagon.take_capacity
    elsif wagon.type == 'Cargo'
      print 'Укажите какой объем необходимо занять: '
      capacity_value = get_choice(gets.chomp)
      wagon.take_capacity(capacity_value)
    end
    puts "Место в вагоне #{wagon.number} забронировано."
  end

  def get_choice(value)
    exit if value.downcase == 'q'
    Integer(value)
  rescue StandardError
    print 'Необходимо указать номер действия: '
    get_choice(gets.chomp)
  end

  def wagon_used?(wagon)
    train_repo.each do |train|
      next unless wagon.type == train.type
      return true if train.wagons.include?(wagon)
    end

    false
  end

  def print_train_list
    train_repo.each { |train| print_train_info(train) }
    print 'Укажите ID поезда для обработки: '
  end

  def print_train_info(train)
    puts "ID #{train_repo.index(train) + 1}. " \
         "Поезд #{train.number} (#{train.type}), " \
         "вагонов: #{train.wagons.count}, скорость: #{train.speed}"
  end

  def make_new_wagon(type)
    print 'Укажите производителя: '
    manufacturer = gets.chomp
    print 'Укажите вместительность вагона: '
    capacity = get_choice(gets.chomp)
    wagon = if type == 'Cargo'
              CargoWagon.new(manufacturer, capacity)
            else
              PassengerWagon.new(manufacturer, capacity)
            end

    wagon_repo.push(wagon)
    wagon
  end

  def print_wagon_list
    wagon_repo.each { |wagon| print_wagon_info(wagon) }

    print 'Укажите ID вагона для обработки: '
  end

  def print_wagon_info(wagon)
    puts "ID #{wagon_repo.index(wagon) + 1}. Вагон №#{wagon.number} " \
         "(#{wagon.type}), произведен #{wagon.manufacturer}, " \
         "вместительность #{wagon.capacity}, свободно #{wagon.free_capacity}"
  end

  def print_unused_wagon_list
    wagon_repo.each do |wagon|
      next unless wagon.type == train.type
      next if wagon_used?(wagon)

      print_wagon_info(wagon)
    end

    print 'Укажите ID вагона для добавления к поезду: '
  end

  def print_station_list
    station_repo.each { |station| print_station_info(station) }
  end

  def print_station_info(station)
    puts "ID #{station_repo.index(station) + 1}. Станция #{station.name}"
  end

  def print_error(exception)
    puts exception.message
    puts 'Укажите параметры повторно!'
  end
end
