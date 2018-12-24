module ProjectManagement
  class CommandHandler
    InvalidTransition = Class.new(StandardError)

    def initialize(event_store)
      @event_store = event_store
    end

    def create(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Issue::InvalidTransition unless issue.can_create?
        IssueOpened.new(data: { issue_id: issue.id })
      end
    end

    def resolve(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Issue::InvalidTransition unless issue.can_resolve?
        IssueResolved.new(data: { issue_id: issue.id })
      end
    end

    def close(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Issue::InvalidTransition unless issue.can_close?
        IssueClosed.new(data: { issue_id: issue.id })
      end
    end

    def reopen(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Issue::InvalidTransition unless issue.can_reopen?
        IssueReopened.new(data: { issue_id: issue.id })
      end
    end

    def start(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Issue::InvalidTransition unless issue.can_start?
        IssueProgressStarted.new(data: { issue_id: issue.id })
      end
    end

    def stop(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Issue::InvalidTransition unless issue.can_stop?
        IssueProgressStopped.new(data: { issue_id: issue.id })
      end
    end

    private

    attr_reader :event_store

    def stream_name(id)
      "Issue$#{id}"
    end

    def with_aggregate(id)
      state = IssueProjection.new(event_store).call(Issue.new.tap { |i| i.id = id }, stream_name(id))
      event = yield state.issue
      event_store.publish(event, stream_name: stream_name(id), expected_version: state.version)
    end
  end
end