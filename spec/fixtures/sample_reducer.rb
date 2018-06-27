class SampleReducer < Rydux::Reducer
  @@initial_state = {
    wow: 'now'
  }

  def self.map_state(action, state = @@initial_state)
    case action[:type]
    when 'ADD_TOAST'
      state.merge(toast: true)
    when 'APPEND_PAYLOAD'
      state.merge(action[:payload])
    else
      state
    end
  end

end
