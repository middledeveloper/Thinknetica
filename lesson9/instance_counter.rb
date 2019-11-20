# frozen_string_literal: true

module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def instances
      instance
    end

    protected

    attr_accessor :instance

    def register
      self.instance ||= 0
      self.instance += 1
    end
  end

  module InstanceMethods
    def register_instance
      self.class.send(:register)
    end
  end
end
