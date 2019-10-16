print "Введите коэффециент A: "
a = gets.chomp.to_f

print "Введите коэффециент B: "
b = gets.chomp.to_f

print "Введите коэффециент C: "
c = gets.chomp.to_f

dscr = b**2 - 4 * a * c

if(dscr == 0)
  x1 = (-b) / (2 * a)
  puts "Дискриминант: #{dscr}, корень равен #{x1}"
elsif(dscr > 0)
  x1 = (-b + Math.sqrt(dscr)) / (2 * a)
  x2 = (-b - Math.sqrt(dscr)) / (2 * a)
  puts "Дискриминант: #{dscr}, корень #1 равен #{x1}, корень #2 равен #{x2}"
else
  puts "Дискриминант: #{dscr}, корней нет"
end
