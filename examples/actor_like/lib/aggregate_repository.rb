class AggregateRepository
  def initialize(event_store)
    @event_store = event_store
  end

  def with_state(state, stream)
    @event_store.read.stream(stream).each { |event| state.call(event) }

    store = ->(event) do
      @event_store.append(event, stream_name: stream)
      true
    end
    yield state, store
  end
end
