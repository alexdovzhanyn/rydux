class SampleListener
  attr_reader :store_state

  def initialize
    @store_state = Store.state
  end

  def state_changed(state)
    @store_state = state
  end

  def subscribe_as_block
    Store.subscribe{|state| [:sample] }
  end

  def subscribe_as_reference
    Store.subscribe(self)
  end
end
