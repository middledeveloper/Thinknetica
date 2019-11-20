# frozen_string_literal: true

require_relative 'accessors_test_class'

test = AccessorsTestClass.new
puts test.inspect

puts 'TEST: attr_accessor_with_history'
puts '---'

test.alpha_attr = 0
test.alpha_attr = 200
test.alpha_attr = 400
test.alpha_attr = 600
test.alpha_attr = 800
test.alpha_attr = 1000

puts "Attribute current value: #{test.alpha_attr.inspect}"
puts 'Attribute value history:'
puts test.alpha_attr_history
puts

puts 'TEST: strong_attr_accessor'
puts '---'
test.gamma_attr = 'Vodka balalayka'
puts test.gamma_attr.inspect
test.gamma_attr = 'Russian nevalyashka'
puts test.gamma_attr.inspect
test.gamma_attr = 666
