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
    # seed

    loop do
      show_menu
      choice = get_choice(gets.chomp)
      menu_cases(choice)
    end
  end

  def menu_cases(choice)
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

  private

  def show_menu
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
    prepare_train_and_add_to_repo(type, number, speed)
  rescue StandardError => e
    print_error(e)
    retry
  end

  def prepare_train_and_add_to_repo(type, number, speed)
    train = if type == 2
              CargoTrain.new(number, speed)
            else
              PassengerTrain.new(number, speed)
            end
    train_repo.push(train)
    puts "Поезд #{train.number} #{train.type} создан, скорость #{train.speed}!"
  end

  def create_route
    if station_repo.count < 2
      puts 'Недостаточно станций для создания маршрута'
    else
      prepare_route_stations
    end
  rescue StandardError => e
    print_error(e)
    retry
  end

  def prepare_route_stations
    print_station_list
    print 'Укажите сначала начальную, а затем конечную станции: '
    first_station = choose_station_by_index(get_choice(gets.chomp) - 1)
    last_station = choose_station_by_index(get_choice(gets.chomp) - 1)
    add_route_to_repo(first_station, last_station)
  end

  def choose_station_by_index(index)
    station_repo[index]
  end

  def add_route_to_repo(first_station, last_station)
    route_repo.push(Route.new(first_station, last_station))
  end

  def set_route
    if train_repo.count.zero?
      puts 'Не создано ни одного поезда'
    elsif route_repo.count.zero?
      puts 'Не создано ни одного маршрута'
    else
      train = define_train_for_route
      route = define_route_to_add
      train.bind_route(route)
    end
  end

  def define_train_for_route
    print_train_list
    train_repo[get_choice(gets.chomp) - 1]
  end

  def print_route_list
    route_repo.each do |route|
      puts "Маршрут #{route_repo.index(route) + 1}"
    end

    print 'Укажите маршрут для добавления: '
  end

  def define_route_to_add
    print_route_list
    route_repo[get_choice(gets.chomp) - 1]
  end

  def add_wagon
    print_train_list
    train = train_repo[get_choice(gets.chomp) - 1]
    wagon = prepate_wagon_to_add(train)
    train.add_wagon(wagon)
    puts "Вагон #{wagon.type} добавлен к поезду #{train.number}!"
  rescue StandardError => e
    print_error(e)
    retry
  end

  def prepate_wagon_to_add(train)
    print "Укажите 1 'Создать вагон', или 2 'Использовать существующий': "
    choice = get_choice(gets.chomp)

    if choice == 1
      make_new_wagon(train.type)
    elsif choice == 2
      print_unused_wagon_list
      wagon_repo[get_choice(gets.chomp) - 1]
    end
  end

  def remove_wagon
    train_repo.each do |train|
      print_train_info(train) if train.wagons.count.positive?
    end

    print 'Укажите от какого поезда следует отцепить вагон: '
    remove_wagon_by_train_index(get_choice(gets.chomp) - 1)
  rescue StandardError => e
    print_error(e)
    retry
  end

  def remove_wagon_by_train_index(index)
    train = train_repo[index]
    train.remove_wagon(train.wagons.last)
    puts "Вагон поезда #{train.number} отцеплен"
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

      show_station_details(station)
    end
  end

  def show_station_details(station)
    unless station.trains.empty?
      station.trains.each { |train| print_train_info(train) }
    end
  end

  def proc_monitor
    station_repo.each do |station|
      if !station.trains.empty?
        show_proc_monitor_details(station)
      else
        puts "На станции #{station.name} поездов нет"
      end
    end
  end

  def show_proc_monitor_details(station)
    puts "На станции #{station.name} поездов: #{station.trains.count}"
    station.trains_on_station(&procs[:station])
    station.trains.each { |train| train.wagons_in_train(&procs[:train]) }
  end

  def take_capacity
    print_wagon_list
    wagon = wagon_repo[get_choice(gets.chomp) - 1]
    take_capacity_by_type(wagon)

    puts "Место в вагоне #{wagon.number} забронировано."
  end

  def take_capacity_by_type(wagon)
    if wagon.type == 'Passenger'
      wagon.take_capacity
    else
      print 'Укажите какой объем необходимо занять: '
      wagon.take_capacity(get_choice(gets.chomp))
    end
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

  def seed
    station_repo.push(Station.new('Санкт-Петербург'))
    station_repo.push(Station.new('Тихвин'))
    station_repo.push(Station.new('Пикалево'))
    station_repo.push(Station.new('Бокситогорск'))
    station_repo.push(Station.new('Горка'))
    station_repo.push(Station.new('Дыми'))
    puts Station.all

    puts 'route1 creation'
    route1 = Route.new(station_repo[1], station_repo[0])
    puts 'route1 add_station'
    route1.add_station(station_repo[2])

    route1.stations_history

    puts 'route2 creation'
    route2 = Route.new(station_repo[2], station_repo[1])
    puts 'route2 stations changing'
    route2 = Route.new(station_repo[2], station_repo[0])
    puts 'route2 end'

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
