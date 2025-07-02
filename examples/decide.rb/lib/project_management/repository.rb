# frozen_string_literal: true

module ProjectManagement
  class Repository
    def initialize(event_store)
      @event_store = event_store
    end

    def load(id, decider)
      stream = @event_store
        .read
        .stream(stream_name(id))

      @expected_version = stream.count - 1

      stream.reduce(decider.initial_state, &decider.evolve)
    end

    def store(id, events)
      @event_store.append(
        events,
        stream_name: stream_name(id),
        expected_version: @expected_version
      )
    end

    private

    def stream_name(id) = "Issue$#{id}"
  end
end
