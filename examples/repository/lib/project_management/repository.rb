module ProjectManagement
  class Repository
    def initialize(event_store)
      @store = event_store
    end

    def load(id)
      store.read.stream(stream_name(id)).to_a
    end

    def save(id, changes)
      store.publish(changes, stream_name: stream_name(id))
    end

    private

    attr_reader :store

    def stream_name(id)
      "Issue$#{id}"
    end
  end
end
