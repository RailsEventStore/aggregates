module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
    end

    def create(cmd)
      with_state(cmd.id) do |state|
        Issue::Create.new.(state)
      end
    end

    def resolve(cmd)
      with_state(cmd.id) do |state|
        Issue::Resolve.new.(state)
      end
    end

    def close(cmd)
      with_state(cmd.id) do |state|
        Issue::Close.new.(state)
      end
    end

    def reopen(cmd)
      with_state(cmd.id) do |state|
        Issue::Reopen.new.(state)
      end
    end

    def start(cmd)
      with_state(cmd.id) do |state|
        Issue::Start.new.(state)
      end
    end

    def stop(cmd)
      with_state(cmd.id) do |state|
        Issue::Stop.new.(state)
      end
    end

    private
    attr_reader :event_store

    def stream_name(id)
      "Issue$#{id}"
    end

    def with_state(id)
      version = -1
      state   = IssueState.new(id)
      event_store.read.stream(stream_name(id)).each do |event|
        state.apply(event)
        version += 1
      end
      events = yield state
      event_store.publish(events, stream_name: stream_name(id), expected_version: version)
    end
  end
end