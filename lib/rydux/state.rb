require 'ostruct'

module Rydux
  class State < OpenStruct
    def initialize(state)
      state = state.clone
      super(state)
      @structure = state
    end

    def to_s
      @structure.inspect
    end

    def inspect
      @structure.inspect
    end

    def method_missing(method)
      if self[method].is_a? Hash
        self[method] = self.class.new(self[method])
      else
        self[method]
      end
    end
  end
end
