# frozen_string_literal: true

require_relative 'accessors'

class AccessorsTestClass
  include Accessors

  attr_accessor_with_history :alpha_attr, :beta_attr
  strong_attr_accessor :gamma_attr, String
end
