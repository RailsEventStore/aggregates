module ProjectManagement
  class Repository
    def initialize(event_store)
      @event_store = event_store
    end

    def load(id, initial_state)
      query =
        @event_store
        .read
        .stream(stream_name(id))
      IssueProjection.call(query, initial_state)
    end

    def store(id, events)
      @event_store.append(events, stream_name: stream_name(id))
    end

    private

    def stream_name(id) = "Issue$#{id}"
  end
end