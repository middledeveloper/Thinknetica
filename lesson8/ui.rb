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
  attr_reader :station_repo, :route_repo, :train_repo, :wagon_repo

  def initialize
    @station_repo = []
    @route_repo = []
    @train_repo = []
    @wagon_repo = []
  end

  def work
    show_main_menu
    choice = get_choice(gets.chomp)

    while choice.class == String
      print 'Необходимо указать номер пункта меню! Укажите повторно: '
      choice = get_choice(gets.chomp)
    end

    until choice.nil?
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
      else
        print 'Некорректное значение, повторите ввод!'
        choice = get_choice(gets.chomp)
      end

      puts
      show_main_menu
      choice = get_choice(gets.chomp)
    end
  end

  private

  # private due methods for UI class only

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
    puts e.message
    puts 'Укажите параметры повторно!'
    retry
  end

  def create_train
    puts '1. Пассажирский'
    puts '2. Грузовой'
    print 'Укажите тип поезда: '
    type = get_choice(gets.chomp)
    print 'Укажите номер поезда: '
    number = gets.chomp
    print 'Укажите скорость поезда: '
    speed = get_choice(gets.chomp)

    if type == 1
      train = PassengerTrain.new(number, speed)
    elsif type == 2
      train = CargoTrain.new(number, speed)
    end

    train_repo.push(train)
    puts "Поезд #{train.number} (#{train.type}) успешно создан, " \
         "скорость #{train.speed}!"
  rescue StandardError => e
    puts e.message
    puts 'Укажите параметры повторно!'
    retry
  end

  def create_route
    if station_repo.count < 2
      puts 'Недостаточно станций для создания маршрута'
    else
      station_repo.each do |station|
        puts "#{station_repo.index(station) + 1}. " \
             "Станция '#{station.name}'"
      end

      print 'Необходимо указать начальную станцию: '
      first_station = station_repo[get_choice(gets.chomp) - 1]
      print 'Необходимо указать конечную станцию: '
      last_station = station_repo[get_choice(gets.chomp) - 1]

      route = Route.new(first_station, last_station)
      route_repo.push(route)
      puts route_repo
    end
  rescue StandardError => e
    puts e.message
    puts 'Укажите параметры повторно!'
    retry
  end

  def set_route
    if train_repo.count.zero?
      puts 'Не создано ни одного поезда'
    elsif route_repo.count.zero?
      puts 'Не создано ни одного маршрута'
    else
      train_repo.each do |train|
        puts "#{train_repo.index(train) + 1}. " \
             "Поезд '#{train.number}', #{train.type}"
      end
      print 'Укажите какому поезду следует задать маршрут: '
      train_add_route = train_repo[get_choice(gets.chomp) - 1]
      route_repo.each do |route|
        puts "Маршрут #{route_repo.index(route) + 1}."
        puts r.stations
      end

      print 'Укажите маршрут для добавления: '
      train_add_route.set_route(route_repo[get_choice(gets.chomp) - 1])
      puts train_add_route.inspect
    end
  end

  def add_wagon
    train_repo.each do |train|
      puts "#{train_repo.index(train) + 1}. " \
           "Поезд '#{train.number}' (#{train.type}), " \
           "вагонов: #{train.wagons.count}, скорость: #{train.speed}"
    end
    print 'Укажите к какому поезду следует добавить вагон: '
    train = train_repo[get_choice(gets.chomp) - 1]
    puts
    puts '1. Создать вагон'
    puts '2. Использовать существующий вагон'
    print 'Укажите действие: '
    choice = get_choice(gets.chomp)
    puts

    if choice == 1
      print 'Укажите производителя: '
      manufacturer = gets.chomp
      puts

      if train.type == 'Passenger'
        print 'Укажите количество мест в вагоне: '
        capacity = get_choice(gets.chomp)
        new_wagon = PassengerWagon.new(manufacturer, capacity)
      elsif train.type == 'Cargo'
        print 'Укажите объем вместительности: '
        capacity = get_choice(gets.chomp)
        new_wagon = CargoWagon.new(manufacturer, capacity)
      end

      wagon_repo.push(new_wagon)
    elsif choice == 2
      wagon_repo.each do |wagon|
        next unless wagon.type == train.type

        wagon_used = wagon_used?(wagon)
        next if wagon_used

        puts "#{wagon_repo.index(wagon) + 1}. Вагон №#{wagon.number} типа " \
             "'#{wagon.type}', произведен #{wagon.manufacturer}, " \
             "вместительность #{wagon.capacity}"
      end
      print 'Укажите вагон для добавления к поезду: '
      new_wagon = wagon_repo[get_choice(gets.chomp) - 1]
    end

    train.add_wagon(new_wagon)
    puts "Вагон #{new_wagon.type}, произведенный #{new_wagon.manufacturer}, " \
         "добавлен к поезду #{train.number}!"
    puts "Теперь количество вагонов в составе: #{train.wagons.count} шт."
  rescue StandardError => e
    puts e.message
    puts 'Укажите параметры повторно!'
    retry
  end

  def remove_wagon
    train_repo.each do |train|
      if t.wagons.count.positive?
        puts "#{train_repo.index(train) + 1}. Поезд '#{train.number}' " \
             "(#{train.type}), вагонов: #{train.wagons.count}"
      end
    end
    print 'Укажите от какого поезда следует отцепить вагон: '
    train = train_repo[get_choice(gets.chomp) - 1]
    puts "Поезд номер #{train.number} выбран"
    train.remove_wagon(train.wagons.last)
  rescue StandardError => e
    puts e.message
    puts 'Укажите параметры повторно!'
    retry
  end

  def move_train
    train_repo.each do |train|
      unless train.route.nil?
        puts "#{train_repo.index(train) + 1}. " \
             "Поезд '#{train.number}', #{train.type}"
      end
    end
    print 'Укажите поезд для передвижения: '
    train_to_move = train_repo[get_choice(gets.chomp) - 1]
    puts '1. Движение вперед'
    puts '2. Движение назад'
    print 'Укажите направление движения поезда: '
    direction = get_choice(gets.chomp)

    if direction == 1
      if train_to_move.station != train_to_move.route.stations.last
        train_to_move.move_forward
      else
        puts 'Поезд на конечной станции'
      end
    elsif direction == 2
      if train_to_move.station != train_to_move.route.stations.first
        train_to_move.move_backward
      else
        puts 'Поезд на начальной станции'
      end
    end
  end

  def station_monitor
    station_repo.each do |station|
      puts "Количество поездов на станции '#{station.name}':" \
           " #{station.trains.count}"
      if s.trains.positive?
        puts 'Поезда на станции:'
        s.trains.each { |train| puts train.number }
      end
    end
  end

  def proc_monitor
    station_proc = proc { |train|
      puts "Поезд '#{train.number}', тип #{train.type}, " \
           "вагонов #{train.wagons.length}"
    }

    train_proc = proc { |wagon|
      puts "Вагон #{wagon.number}, тип #{wagon.type}, " \
           "свободно #{wagon.free_capacity}"
    }

    station_repo.each do |station|
      if !station.trains.empty?
        station.trains_on_station(&station_proc)
        station.trains.each { |train| train.wagons_in_train(&train_proc) }
      else
        puts "На станции #{station.name} поездов нет"
      end
    end
  end

  def take_capacity
    capacity_proc = proc { |wagon|
      if x.type == 'Passenger'
        x.take_capacity
        puts "Пассажирское место в вагоне #{wagon.number} теперь занято."
      elsif x.type == 'Cargo'
        print 'Укажите какой объем необходимо занять: '
        capacity_value = get_choice(gets.chomp)
        x.take_capacity(capacity_value)
        puts "Место в грузовом вагоне #{wagon.number} теперь занято."
      end
    }

    wagon_repo.each do |wagon|
      puts "#{wagon_repo.index(wagon) + 1}. Вагон #{wagon.number}, " \
           "тип #{wagon.type}, свободно #{wagon.free_capacity}"
    end
    print 'Укажите номер вагона для бронирования места: '
    wagon = wagon_repo[get_choice(gets.chomp) - 1]

    capacity_proc.call(wagon)
  end

  def get_choice(value)
    exit if value.downcase == 'q'
    value.to_i
  end

  def wagon_used?(wagon)
    train_repo.each do |train|
      next unless wagon.type == train.type
      return true if train.wagons.include?(wagon)
    end

    false
  end
end
