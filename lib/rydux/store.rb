module Rydux
  class Store
    attr_reader :listeners

    def initialize(reducers)
      @state, @listeners = {}, []
      @reducers = strap_reducers(reducers)
    end

    # Allow subscribing either by passing a reference to self
    # or by passing a block which defines the state keys that
    # this listener cares about
    def subscribe(caller = nil, &block)
      if block_given?
        notify_when = block.call(state)
        @listeners << { obj: block.binding.receiver, notify_when: notify_when }
      else
        @listeners << { obj: caller }
      end
    end

    # Unsubscribes a listener from the store
    def abandon(listener)
      @listeners.delete_if {|l| l[:obj] == listener }
    end

    # Dispatches an action to all reducers. Can be called any of the following ways:
    # Takes in an action and an optional callback proc, which will be called after the
    # dispatch is finished.
    # The action can be passed in either as a hash or as two seperate arguments.
    # E.g. dispatch({ type: 'SOME_ACTION', payload: { key: 'value' } })
    # is the same as dispatch('SOME_ACTION', { key: 'value' })
    # Here's an example with a proc: dispatch('SOME_ACTION', { key: 'value' }, ->{ puts "The dispatch is done" })
    def dispatch(*args)
      if args.first.is_a? Hash
        _dispatch(args.first, args[1])
      else
        if args[1].is_a? Proc
          _dispatch({ type: args.first }, args[1])
        else
          _dispatch({ type: args.first, payload: args[1] }, args[2])
        end
      end
    end

    # Return a clone of the current state so that the user cannot directly
    # modify state, and introduce side effects
    def state
      State.new(@state)
    end

    private

      def _dispatch(action, callback = ->{})
        @reducers.each {|k, reducer| set_state *[k, reducer.map_state(action, state[k])] }
        callback.call if callback
      end

      # Initialize state with the key-value pair associated with each reducer
      def strap_reducers(reducers)
        reducers.each {|k, reducer| set_state *[k, reducer.map_state(type: nil)]}
        reducers
      end

      # Argument 1 should always be the key within state that we're mutating
      # Argument 2 should be the actual state object
      def set_state(k, v)
        if @state[k] != v # Only set state if it has actually changed
          @state[k] = v

          if !self.methods.include? k
            self.define_singleton_method(k.to_sym) do
              return State.new(@state[k])
            end
          end

          notify_listeners(k)
        end
      end

      def notify_listeners(state_key)
        @listeners.each do |listener|
          # If no notify_when, the user wants ALL state notifications
          # Otherwise, only send the state notifications they've subscribed to.
          if !listener[:notify_when] && listener[:obj].respond_to?(:state_changed)
            listener[:obj].public_send(:state_changed, state)
          elsif listener[:notify_when].include?(state_key) && listener[:obj].respond_to?(:state_changed)
            listener[:obj].public_send(:state_changed, State.new(state[state_key]))
          end
        end
      end

  end
end
