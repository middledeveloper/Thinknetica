# frozen_string_literal: true

module Accessors
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def attr_accessor_with_history(*attrs)
      attrs.each do |attr|
        attribute_variable = "@#{attr}".to_sym

        define_method(attr) do
          instance_variable_get(attribute_variable)
        end

        define_method("#{attr}=".to_sym) do |value|
          @history ||= {}
          (@history[attr] ||= []).push(value)
          instance_variable_set(attribute_variable, value)
        end

        define_method("#{attr}_history".to_sym) do
          @history[attr]
        end
      end
    end

    def strong_attr_accessor(attr_name, class_name)
      name_variable = "@#{attr_name}".to_sym

      define_method(attr_name) do
        instance_variable_get(name_variable)
      end

      define_method("#{attr_name}=".to_sym) do |value|
        unless value.instance_of? class_name
          raise "Некорректно указан класс '#{class_name}'"
        end

        instance_variable_set(name_variable, value)
      end
    end
  end
end
