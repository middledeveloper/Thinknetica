fibonacci = Array.new
num = 0

loop do
  if num > 1
    current = (fibonacci[-1]) + (fibonacci[-2])
    break if current > 100
  else
    current = num
  end
  fibonacci.push(current)
  num += 1
end

print(fibonacci.join(','))
