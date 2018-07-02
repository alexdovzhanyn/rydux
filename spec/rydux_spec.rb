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

  it "can dispatch without passing in a hash" do
    store = Rydux::Store.new(sample: SampleReducer)
    store.dispatch('ADD_TOAST')

    expect(store.sample.toast).to eq(true)
  end

  it "can dispatch with a payload without passing in a hash" do
    store = Rydux::Store.new(sample: SampleReducer)
    store.dispatch('APPEND_PAYLOAD', { appended_without_hash: true })

    expect(store.sample.appended_without_hash).to eq(true)
  end

  it "can call a callback function after a dispatch" do
    store = Rydux::Store.new(sample: SampleReducer)
    store.dispatch('APPEND_PAYLOAD', { name: 'Alex' }, ->{ store.dispatch('APPEND_PAYLOAD', { name: 'Mike' }) })

    expect(store.sample.name).to eq('Mike')
  end

  it "can call a callback function after a dispatch without a payload" do
    store = Rydux::Store.new(sample: SampleReducer)
    store.dispatch('ADD_TOAST', ->{ store.dispatch('APPEND_PAYLOAD', { name: 'Mike' }) })

    expect(store.sample.name).to eq('Mike')
  end

  it "can subscribe to the store as reference" do
    sample = SampleListener.new
    sample.subscribe_as_reference
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: { new_data: 'Blah' })

    expect(sample.store_state.sample.new_data).to eq('Blah')
  end

  it "can unsubscribe from the store as reference" do
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: { some_data: 'Wow!' })
    sample = SampleListener.new
    sample.subscribe_as_reference
    Store.abandon(sample)
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: {some_data: 'No!' })

    expect(sample.store_state.sample.some_data).to eq('Wow!')
  end

  it "can subscribe to the store as block" do
    sample = SampleListener.new
    sample.subscribe_as_block
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: { new_data: 'Blah' })

    expect(sample.store_state.sample.new_data).to eq('Blah')
  end

  it "can unsubscribe from the store as reference" do
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: { some_data: 'Wow!' })
    sample = SampleListener.new
    sample.subscribe_as_block
    Store.abandon(sample)
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: {some_data: 'No!' })

    expect(sample.store_state.sample.some_data).to eq('Wow!')
  end

  it "can receive only relevent notifications when subscribing as block" do
    sample = SampleListener.new
    sample.subscribe_as_block
    Store.dispatch(type: 'A_FAKE_ACTION', payload: { some_fake_data: 'NAH' })
    Store.dispatch(type: 'APPEND_PAYLOAD', payload: { real_data: true })

    expect(sample.store_state.some_fake_data).to eq(nil)
    expect(sample.store_state.real_data).to eq(true)
  end
end
