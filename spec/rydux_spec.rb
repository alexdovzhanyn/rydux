RSpec.describe Rydux do
  require "pry"
  Store = Rydux::Store.new(sample: SampleReducer)

  it "has a version number" do
    expect(Rydux::VERSION).not_to be nil
  end

  it "can initialize with state" do
    store = Rydux::Store.new(sample: SampleReducer)

    expect(store.sample.wow).to eq('now')
  end

  it "can set state" do
    store = Rydux::Store.new(sample: SampleReducer)
    store.dispatch(type: 'ADD_TOAST')

    expect(store.sample.toast).to eq(true)
  end

  it "can subscribe to the store" do
    sample = SampleListener.new
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: { new_data: 'Blah' })

    expect(sample.store_state.sample.new_data).to eq('Blah')
  end

  it "can unsubscribe from the store" do
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: { some_data: 'Wow!' })
    sample = SampleListener.new
    Store.abandon(sample)
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: {some_data: 'No!' })

    expect(sample.store_state.sample.some_data).to eq('Wow!')
  end
end