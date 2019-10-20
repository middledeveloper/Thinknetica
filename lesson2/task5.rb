puts 'Укажите год (4 цифры): '
year = gets.chomp.to_i
puts 'Укажите месяц: '
month = gets.chomp.to_i
puts 'Укажите число : '
day = gets.chomp.to_i

interscalary =
  year % 4 == 0 || (year % 100 == 0 && year % 400 == 0) ? true : false

months = {
  1 => 31,
  2 => interscalary ? 28 : 29,
  3 => 31,
  4 => 30,
  5 => 31,
  6 => 30,
  7 => 31,
  8 => 31,
  9 => 30,
  10 => 31,
  11 => 30,
  12 => 31
}

day_of_year = day
iterator = 1
while(iterator < month)
  day_of_year += months[iterator]
  iterator += 1
end

puts "Указанная дата является #{day_of_year} днем в #{year} году"

=begin
# Без ограничений сделал бы так:
require 'date'

default_date = Date.new(year)
user_date = Date.new(year, month, day)
day_of_year = (user_date - default_date).to_i + 1
=end
