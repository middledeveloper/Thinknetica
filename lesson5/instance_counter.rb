# frozen_string_literal: true

module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    attr_reader :instances

    def set_instances
      @instances = @instances.nil? ? 1 : @instances += 1
    end
  end

  module InstanceMethods
    private

    def register_instance
      self.class.set_instances
    end
  end
end
