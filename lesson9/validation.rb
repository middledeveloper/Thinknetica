# frozen_string_literal: true

module Validation
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def validate(_attr_name, validation_type, checker = nil)
      # получить значение атрибута для дальнейшей валидации
      _attr_name do |value|
        presence(value) if validation_type == :presence
        format(value, checker) if validation_type == :format
        validate_type(value, checker) if validation_type == :type
      end
    end

    private

    def presence(value)
      return if value.nil? || value.empty?

      raise StandardError, 'Значение не задано!'
    end

    def format(value, format)
      return if instance_variable_get(value) !~ format

      raise StandardError, 'Формат параметра некоррекный!'
    end

    def validate_type(value, value_class)
      return unless instance_variable_get(value).instance_of? value_class

      raise StandardError, 'Класс значения некорректный!'
    end
  end

  module InstanceMethods
    def validate!
      self.class.validate
    end

    def valid?
      validate!
      true
    rescue StandardError
      false
    end
  end
end
