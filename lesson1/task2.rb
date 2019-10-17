print 'Введите основание треугольника: '
triangle_base = gets.chomp.to_f

print 'Введите высоту треугольника: '
triangle_height = gets.chomp.to_f

area = 1.0 / 2.0 * triangle_base * triangle_height
puts "Площадь треугольника: #{area}"
