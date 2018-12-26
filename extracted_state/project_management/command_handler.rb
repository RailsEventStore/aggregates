module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
    end

    def create(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.create
      end
    end

    def resolve(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.resolve
      end
    end

    def close(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.close
      end
    end

    def reopen(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.reopen
      end
    end

    def start(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.start
      end
    end

    def stop(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.stop
      end
    end

    private
    attr_reader :event_store

    def stream_name(id)
      "Issue$#{id}"
    end

    def with_aggregate(id)
      version = -1
      state   = IssueState.new(id)
      event_store.read.stream(stream_name(id)).each do |event|
        state.apply(event)
        version += 1
      end
      yield issue = Issue.new(state)
      event_store.publish(issue.changes, stream_name: stream_name(id), expected_version: version)
    end
  end
end