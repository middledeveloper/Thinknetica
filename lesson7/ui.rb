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
        print 'Укажите количество мест в вагоне: '
        capacity = get_choice(gets.chomp)
        wagon = PassengerWagon.new(manufacturer, capacity)
      elsif train.type == 'Cargo'
        print 'Укажите объем вместительности: '
        capacity = get_choice(gets.chomp)
        wagon = CargoWagon.new(manufacturer, capacity)
      end

      wagon_repo.push(wagon)
    elsif choice == 2
      wagon_repo.each do |w|
        next unless w.type == train.type

        wagon_used = wagon_used?(w)
        next if wagon_used

        puts "#{wagon_repo.index(w) + 1}. Вагон №#{w.number} типа " \
             "'#{w.type}', произведен #{w.manufacturer}, " \
             "вместительность #{w.capacity}"
      end
      print 'Укажите вагон для добавления к поезду: '
      wagon = wagon_repo[get_choice(gets.chomp) - 1]
    end

    train.add_wagon(wagon)
    puts "Вагон #{wagon.type}, произведенный #{wagon.manufacturer}, " \
         "добавлен к поезду #{train.number}!"
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

  def proc_monitor
    station_proc = proc { |t| puts "Поезд '#{t.number}', тип #{t.type}, вагонов #{t.wagons.length}" }
    train_proc = proc { |w| puts "Вагон #{w.number}, тип #{w.type}, свободно #{w.free_capacity}" }

    station_repo.each do |s|
      if !s.trains.empty?
        s.trains_on_station(&station_proc)
        s.trains.each { |t| t.wagons_in_train(&train_proc) }
      else
        puts "На станции #{s.name} поездов нет"
      end
    end
  end

  def take_capacity
    capacity_proc = proc { |x|
      if x.type == 'Passenger'
        x.take_capacity
        puts "Пассажирское место в вагоне #{x.number} теперь занято."
      elsif x.type == 'Cargo'
        print 'Укажите какой объем необходимо занять: '
        capacity_value = get_choice(gets.chomp)
        x.take_capacity(capacity_value)
        puts "Место в грузовом вагоне #{x.number} теперь занято."
      end
    }

    wagon_repo.each do |w|
      puts "#{wagon_repo.index(w) + 1}. Вагон #{w.number}, " \
      "тип #{w.type}, свободно #{w.free_capacity}"
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

  def seed
    station_repo.push(Station.new('Санкт-Петербург'))
    station_repo.push(Station.new('Тихвин'))
    station_repo.push(Station.new('Пикалево'))
    station_repo.push(Station.new('Бокситогорск'))
    station_repo.push(Station.new('Горка'))
    station_repo.push(Station.new('Дыми'))
    puts Station.all

    route1 = Route.new(station_repo[1], station_repo[0])
    route1.add_station(station_repo[2])

    route2 = Route.new(station_repo[2], station_repo[1])

    route_repo.push(route1, route2)

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

    puts "Train #{train1.number} is valid? : #{train1.valid?}"

    train1.set_route(route1)
    train2.set_route(route2)

    w1 = CargoWagon.new('Rails Cargo Inc', 700)
    w2 = CargoWagon.new('Rails Cargo Inc', 600)
    w3 = CargoWagon.new('Rails Cargo Inc', 650)
    w4 = CargoWagon.new('Rails Cargo Inc', 600)
    w5 = CargoWagon.new('Rails Cargo Inc', 700)
    w6 = CargoWagon.new('Rails Cargo Inc', 500)
    w7 = PassengerWagon.new('XTR Wagons', 80)
    w8 = PassengerWagon.new('Civil Wagon Group', 90)
    w9 = PassengerWagon.new('Loyal Federation', 75)
    w10 = PassengerWagon.new('Civil Wagon Group', 90)
    w11 = PassengerWagon.new('Grey Lion Pride', 80)
    w12 = PassengerWagon.new('Civil Wagon Group', 90)

    puts "RANDOM NUMBERS CHECKING: #{w1.number}, #{w2.number}, #{w3.number}, " \
    "#{w4.number} #{w5.number}"

    wagon_repo.push(w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12)
    puts "WAGON REPO COUNT: #{wagon_repo.length}"

    train1.add_wagon(w1)
    train1.add_wagon(w2)
    train1.add_wagon(w3)
    train2.add_wagon(w7)
    train2.add_wagon(w8)
    train2.add_wagon(w9)
    train2.add_wagon(w10)

    train1.accelerate(60)

    puts w9.inspect
    w9.take_capacity
    puts w9.inspect
    puts w9.free_capacity
    puts w9.taken_capacity

    puts w1.inspect
    w1.take_capacity(270)
    puts w1.inspect
    puts w1.free_capacity
    puts w1.taken_capacity
  end
end
