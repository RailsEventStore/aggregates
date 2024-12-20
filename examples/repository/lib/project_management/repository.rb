# frozen_string_literal: true

module ProjectManagement
  class Repository
    def initialize(event_store)
      @event_store = event_store
    end

    def load(id)
      @event_store.read.stream(stream_name(id))
    end

    def save(id, events)
      @event_store.append(events, stream_name: stream_name(id))
    end

    private

    def stream_name(id) = "Issue$#{id}"
  end
end
