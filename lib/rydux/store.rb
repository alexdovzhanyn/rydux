module Rydux
  class Store
    attr_reader :listeners

    def initialize(combined_reducers)
      @state = {}
      @listeners = []
      @reducers = combined_reducers

      @reducers.each do |k, reducer|
        if !reducer.ancestors.include? ::Rydux::Reducer
          raise "Store expected a Reducer or array of reducers, but instead got: #{reducers}"
        end

        new_state = {}
        new_state[k] = reducer.map_state(type: nil)

        set_state(new_state)
      end
    end

    def subscribe(listener)
      @listeners << listener
    end

    # Unsubscribes a listener from the store
    def abandon(listener)
      @listeners.delete(listener)
    end

    def dispatch(action)
      @reducers.each do |k, reducer|
        new_state = {}
        new_state[k] = reducer.map_state(action, state[k])
        set_state(new_state)
      end
    end

    def state
      State.new(@state)
    end

    private

      def set_state(new_state)
        new_state.each do |k, v|
          @state[k] = v

          if !self.methods.include? k
            self.define_singleton_method(k.to_sym) do
              return State.new(state[k])
            end
          end

          notify_listeners
        end
      end

      def notify_listeners
        @listeners.each do |listener|
          listener.public_send(:state_changed, state)
        end
      end

  end
end
