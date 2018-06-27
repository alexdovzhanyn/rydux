class SampleListener
  attr_reader :store_state

  def initialize
    Store.subscribe(self)
    @store_state = Store.state
  end

  def state_changed(state)
    @store_state = state
  end
end
