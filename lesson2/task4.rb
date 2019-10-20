alphabet = 'a'..'z'
vowels = ['a', 'e', 'i', 'o', 'u', 'y']

hash = Hash.new
index = 0
alphabet.each do |letter|
  index += 1
  if(vowels.include?(letter))
    hash[letter] = index
  end
end

puts hash
