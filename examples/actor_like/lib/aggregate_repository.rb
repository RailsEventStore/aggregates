class AggregateRepository
  def initialize(event_store)
    @event_store = event_store
  end

  def with_state(state, stream)
    version = -1
    @event_store
      .read
      .stream(stream)
      .each
      .with_index do |event, index|
        state.call(event)
        version = index
      end

    store = ->(event) do
      @event_store.publish(event, stream_name: stream, expected_version: version)
      true
    end
    yield state, store
  end
end
