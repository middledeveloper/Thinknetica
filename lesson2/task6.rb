
hash = Hash.new
active = true

while(active)
  puts 'Введите наименование товара: '
  product_name = gets.chomp
  active = product_name == 'stop' ? false : true

  if(active)
    puts 'Введите стоимость единицы товара: '
    product_price = gets.chomp.to_f
    puts 'Укажите количество единиц товара: '
    product_count = gets.chomp.to_f

    hash[product_name] = { price: product_price, count: product_count }
  else
    puts 'Покупки завершены!'
  end

  total_price = 0
  hash.each do |item, details|
    product_total_price = details[:price] * details[:count]
    total_price += product_total_price
    puts "#{item} (#{details[:price]} руб. за шт., #{details[:count]} шт.): #{product_total_price}"
    puts "Итого: #{total_price} руб."
    puts '***'
    puts
  end
end
