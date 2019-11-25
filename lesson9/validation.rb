# frozen_string_literal: true

module Validation
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    def validate(attr, method, *validates)
      define_method("#{attr}_#{method}_validation") do
        send(method.to_sym, instance_variable_get("@#{attr}"), *validates)
      end
    end
  end

  module InstanceMethods
    def validate!
      public_methods.each do |method|
        send(method) if method =~ /_validation$/
      end
      true
    end

    def valid?
      validate!
      true
    rescue StandardError
      false
    end

    protected

    def presence(value, _validates = nil)
      raise StandardError, 'Значение не задано!' if value.nil? || value.empty?

      puts "PRESENCE: корректно! (#{value})"
      true
    end

    def format(value, regex)
      if value !~ regex
        raise StandardError, "Формат параметра некоррекный! (#{value})"
      end

      puts "FORMAT: корректно! (#{value})"
      true
    end

    def type(value, valid_class)
      unless value.instance_of? valid_class
        raise StandardError, "Класс значения некорректный! (#{value})"
      end

      puts "TYPE: корректно! (#{value})"
      true
    end
  end
end
