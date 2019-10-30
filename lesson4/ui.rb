# frozen_string_literal: true

require_relative 'route'
require_relative 'station'
require_relative 'cargotrain'
require_relative 'passengertrain'
require_relative 'cargowagon'
require_relative 'passengerwagon'

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
        print 'Введите наименование станции: '
        station = Station.new(gets.chomp)
        station_repo.push(station)
        puts station_repo

      when 2
        puts '1. Пассажирский'
        puts '2. Грузовой'
        print 'Укажите тип поезда: '
        type_value = get_choice(gets.chomp)
        print 'Необходимо указать номер поезда: '
        num_value = get_choice(gets.chomp)

        if type_value == 1
          train = PassengerTrain.new(num_value)
        elsif type_value == 2
          train = CargoTrain.new(num_value)
        end

        train_repo.push(train)
        puts train_repo

      when 3
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
      when 4
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
      when 5
        train_repo.each { |t| puts "#{train_repo.index(t) + 1}. Поезд '#{t.number}' (#{t.type}), вагонов: #{t.wagons.count}" }
        print 'Укажите к какому поезду следует добавить вагон: '
        train_add_wagon = train_repo[get_choice(gets.chomp) - 1]
        wagon_repo.each do |w|
          next unless w.type == train_add_wagon.type

          wagon_used = wagon_used?(w)
          unless wagon_used
            puts "#{wagon_repo.index(w) + 1}. Вагон, тип '#{w.type}'"
          end
        end
        print 'Укажите вагон для добавления к поезду: '
        wagon_to_add = wagon_repo[get_choice(gets.chomp) - 1]
        train_add_wagon.add_wagon(wagon_to_add)
        puts "Количество вагонов поезда #{train_add_wagon.number}: #{train_add_wagon.wagons.count}"

      when 6
        train_repo.each do |t|
          if t.wagons.count > 0
            puts "#{train_repo.index(t) + 1}. Поезд '#{t.number}' (#{t.type}), вагонов: #{t.wagons.count}"
          end
        end
        print 'Укажите от какого поезда следует отцепить вагон: '
        train_remove_wagon = train_repo[get_choice(gets.chomp) - 1]
        puts "Поезд номер #{train_remove_wagon.number} выбран"
        train_remove_wagon.remove_wagon(train_remove_wagon.wagons.last)
        puts "Количество вагонов поезда #{train_remove_wagon.number}: #{train_remove_wagon.wagons.count}"

      when 7
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

        puts "Поезд #{train_to_move.number} находится на станции #{train_to_move.station.name}"

      when 8
        station_repo.each do |s|
          puts "Количество поездов на станции '#{s.name}': #{s.trains.count}"
          s.trains.each { |t| puts t.number } if s.trains.count > 0
        end

      else
        print 'Некорректное значение, повторите ввод!'
        choice = get_choice(gets.chomp)
      end

      puts
      show_main_menu
      choice = get_choice(gets.chomp)
    end
  end

  def show_main_menu
    puts '1. Создать станцию'
    puts '2. Создать поезд'
    puts '3. Создать маршрут'
    puts '4. Назначить маршрут поезду'
    puts '5. Добавить вагон к поезду'
    puts '6. Отцепить вагон от поезда'
    puts '7. Перемещение поезда по маршруту'
    puts '8. Просмотр станций и поездов'
    puts '0. ВЫХОД'
    print 'Введите номер необходимого действия: '
  end

  def get_choice(value)
    choice = value.to_i
    exit if choice == 0
    choice
  end

  def wagon_used?(wagon)
    train_repo.each do |train|
      train.wagons.each do
        next unless wagon.type == train.type
        return true if train.wagons.include?(wagon)
      end
    end

    false
  end

  def seed
    station_repo.push(Station.new('Station1'))
    station_repo.push(Station.new('Station2'))
    station_repo.push(Station.new('Station3'))
    station_repo.push(Station.new('Station4'))
    station_repo.push(Station.new('Station5'))
    station_repo.push(Station.new('Station6'))

    route1 = Route.new(station_repo[0], station_repo[1])
    route1.add_station(station_repo[2])

    route_repo.push(route1)
    route_repo.push(Route.new(station_repo[3], station_repo[5]))

    train_repo.push(CargoTrain.new('CRG001'))
    train_repo.push(CargoTrain.new('CRG002'))
    train_repo.push(PassengerTrain.new('PSN001'))
    train_repo.push(PassengerTrain.new('PSN002'))

    train_repo[2].set_route(route1)

    wagon_repo.push(CargoWagon.new)
    wagon_repo.push(CargoWagon.new)
    wagon_repo.push(CargoWagon.new)
    wagon_repo.push(CargoWagon.new)
    wagon_repo.push(CargoWagon.new)
    wagon_repo.push(CargoWagon.new)
    wagon_repo.push(PassengerWagon.new)
    wagon_repo.push(PassengerWagon.new)
    wagon_repo.push(PassengerWagon.new)
    wagon_repo.push(PassengerWagon.new)
    wagon_repo.push(PassengerWagon.new)
    wagon_repo.push(PassengerWagon.new)

    train_repo[0].add_wagon(wagon_repo[0])
    train_repo[2].add_wagon(wagon_repo[7])
  end
end
