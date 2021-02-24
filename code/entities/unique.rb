# frozen_string_literal: true

##
# Makes a class unique
module Unique
  def [](id)
    @instances ||= {}
    @instances[id] ||= new(id)
  end
end
