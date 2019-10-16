puts "Укажите длины сторон треугольника".upcase
print "Введите длину стороны #1: "
side1 = gets.chomp.to_f

print "Введите длину стороны #2: "
side2 = gets.chomp.to_f

print "Введите длину стороны #3: "
side3 = gets.chomp.to_f

right = false #прямоугольный
isosceles = false #равнобедренный
quuilateral = false #равносторонний

if(side1 == side2 && side2 == side3 && side1 == side3)
  isosceles = true
  quuilateral = true
end

if(!quuilateral)
  sides_array = [side1, side2, side3]
  hypotenuse = sides_array.max
  sides_array.delete(hypotenuse)

  other_sides = 0
  sides_array.each{|s| other_sides += s**2}

  if(hypotenuse**2 == other_sides)
    right = true
  end

  if(side1 == side2 || side2 == side3 || side1 == side3)
    isosceles = true
  end
end

puts "Данные о треугольнике:".upcase
puts "Прямоугольный: #{right ? "Да" : "Нет"}"
puts "Равнобедренный: #{isosceles ? "Да" : "Нет"}"
puts "Равносторонний: #{quuilateral ? "Да" : "Нет"}"
