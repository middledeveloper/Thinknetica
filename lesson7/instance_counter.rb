# frozen_string_literal: true

module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    attr_accessor :instances_count

    def instances
      @instances_count ||= 0
    end
  end

  module InstanceMethods
    private

    def register_instance
      self.class.instances_count ||= 0
      self.class.instances_count += 1
    end
  end
end
