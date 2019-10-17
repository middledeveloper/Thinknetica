print 'Введите Ваше имя: '
name = gets.chomp

print 'Введите Ваш рост: '
height = gets.chomp.to_f

optimal_weight = height - 110
if(optimal_weight > 0)
  puts "#{name}, Ваш оптимальный вес составляет #{optimal_weight}"
else
  puts 'Ваш вес уже оптимальный'
end
