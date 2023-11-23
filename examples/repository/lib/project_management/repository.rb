module ProjectManagement
  class Repository
    def initialize(event_store)
      @store = event_store
    end

    def load(id)
      events = store.read.stream(stream_name(id)).to_a
      version = events.size - 1

      [events, version]
    end

    def save(id, current_version, changes)
      store.publish(
        changes,
        stream_name: stream_name(id),
        expected_version: current_version
      )
    end

    private

    attr_reader :store

    def stream_name(id)
      "Issue$#{id}"
    end
  end
end
