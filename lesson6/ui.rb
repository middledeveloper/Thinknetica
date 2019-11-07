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

    # seed
  end

  def work
    show_main_menu
    choice = get_choice(gets.chomp)

    while choice.class == String
      print 'Необходимо указать номер пункта меню! Укажите повторно: '
      choice = get_choice(gets.chomp)
    end

    while choice != 0
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

  # Вынесено в private т.к. методы не используются за пределами класса UI

  def show_main_menu
    puts '1. Создать станцию'
    puts '2. Создать поезд'
    puts '3. Создать маршрут'
    puts '4. Назначить маршрут поезду'
    puts '5. Добавить вагон к поезду'
    puts '6. Отцепить вагон от поезда'
    puts '7. Перемещение поезда по маршруту'
    puts '8. Просмотр станций и поездов'
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
    puts "Поезд #{train.number} (#{train.type}) успешно создан, скорость #{train.speed}!"
  rescue StandardError => e
    puts e.message
    puts 'Укажите параметры повторно!'
    retry
  end

  def create_route
    if station_repo.count < 2
      puts 'Недостаточно станций для создания маршрута'
    else
      station_repo.each { |s| puts "#{station_repo.index(s) + 1}. Станция '#{s.name}'" }

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
      train_repo.each { |t| puts "#{train_repo.index(t) + 1}. Поезд '#{t.number}', #{t.type}" }
      print 'Укажите какому поезду следует задать маршрут: '
      train_add_route = train_repo[get_choice(gets.chomp) - 1]
      route_repo.each do |r|
        puts "Маршрут #{route_repo.index(r) + 1}."
        puts r.stations
      end

      print 'Укажите маршрут для добавления: '
      train_add_route.set_route(route_repo[get_choice(gets.chomp) - 1])
      puts train_add_route.inspect
    end
  end

  def add_wagon
    train_repo.each { |t| puts "#{train_repo.index(t) + 1}. Поезд '#{t.number}' (#{t.type}), вагонов: #{t.wagons.count}, скорость: #{t.speed}" }
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
        wagon = PassengerWagon.new(manufacturer)
      elsif train.type == 'Cargo'
        wagon = CargoWagon.new(manufacturer)
      end

      wagon_repo.push(wagon)
    elsif choice == 2
      wagon_repo.each do |w|
        next unless w.type == train.type

        wagon_used = wagon_used?(w)
        unless wagon_used
          puts "#{wagon_repo.index(w) + 1}. Вагон, тип '#{w.type}' (#{w.manufacturer})"
        end
      end
      print 'Укажите вагон для добавления к поезду: '
      wagon = wagon_repo[get_choice(gets.chomp) - 1]
    end

    train.add_wagon(wagon)
    puts "Вагон #{wagon.type}, произведенный #{wagon.manufacturer}, добавлен к поезду #{train.number}!"
    puts "Теперь количество вагонов в составе: #{train.wagons.count} шт."
  rescue StandardError => e
    puts e.message
    puts 'Укажите параметры повторно!'
    retry
  end

  def remove_wagon
    train_repo.each do |t|
      if t.wagons.count > 0
        puts "#{train_repo.index(t) + 1}. Поезд '#{t.number}' (#{t.type}), вагонов: #{t.wagons.count}"
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
    train_repo.each do |t|
      unless t.route.nil?
        puts "#{train_repo.index(t) + 1}. Поезд '#{t.number}', #{t.type}"
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
    station_repo.each do |s|
      puts "Количество поездов на станции '#{s.name}': #{s.trains.count}"
      if s.trains.count > 0
        puts 'Поезда на станции:'
        s.trains.each { |train| puts train.number }
      end
    end
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

  def seed
    station_repo.push(Station.new('Санкт-Петербург'))
    station_repo.push(Station.new('Тихвин'))
    station_repo.push(Station.new('Пикалево'))
    station_repo.push(Station.new('Бокситогорск'))
    station_repo.push(Station.new('Горка'))
    station_repo.push(Station.new('Дыми'))
    puts Station.all

    route1 = Route.new(station_repo[0], station_repo[1])
    route1.add_station(station_repo[2])

    route_repo.push(route1)
    route_repo.push(Route.new(station_repo[3], station_repo[5]))

    train1 = CargoTrain.new('TNT-00', 0)
    train2 = PassengerTrain.new('DVI70', 0)
    train_repo.push(train1)
    train_repo.push(train2)

    puts "Instance counter:
          Train - #{Train.instances};
          CargoTrain - #{CargoTrain.instances};
          PassengerTrain - #{PassengerTrain.instances}"

    puts 'Train.find testing'
    puts Train.find('NotExists')
    puts Train.find('TNT-00')
    puts

    tr = train_repo[0]
    puts "Train #{tr.number} is valid? : #{tr.valid?}"
    tr.set_route(route1)

    wagon_repo.push(CargoWagon.new('Rails Cargo Inc'))
    wagon_repo.push(CargoWagon.new('Rails Cargo Inc'))
    wagon_repo.push(CargoWagon.new('Rails Cargo Inc'))
    wagon_repo.push(CargoWagon.new('Rails Cargo Inc'))
    wagon_repo.push(CargoWagon.new('Rails Cargo Inc'))
    wagon_repo.push(CargoWagon.new('Rails Cargo Inc'))
    wagon_repo.push(PassengerWagon.new('XTR Wagons'))
    wagon_repo.push(PassengerWagon.new('Civil Wagon Group'))
    wagon_repo.push(PassengerWagon.new('Loyal Federation'))
    wagon_repo.push(PassengerWagon.new('Civil Wagon Group'))
    wagon_repo.push(PassengerWagon.new('Grey Lion Pride'))
    wagon_repo.push(PassengerWagon.new('Civil Wagon Group'))

    train_repo[0].add_wagon(wagon_repo[0])
    train_repo[1].add_wagon(wagon_repo[7])

    train1.accelerate(60)
  end
end
