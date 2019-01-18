class AggregateRepository
  def initialize(event_store)
    @event_store = event_store
  end

  def with_aggregate(aggregate, stream)
    version = :none
    @event_store.read.stream(stream).each.with_index do |event, index|
      aggregate.apply(event)
      version = index
    end

    store = -> event { @event_store.publish(event, stream_name: stream, expected_version: version) }
    yield aggregate, store
  end
end
