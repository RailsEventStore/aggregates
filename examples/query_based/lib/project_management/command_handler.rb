module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
    end

    def call(cmd)
      case cmd
      when CreateIssue
        create(cmd)
      when ResolveIssue
        resolve(cmd)
      when CloseIssue
        close(cmd)
      when ReopenIssue
        reopen(cmd)
      when StartIssueProgress
        start(cmd)
      when StopIssueProgress
        stop(cmd)
      end
    end

    def create(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Error unless issue.can_create?
        IssueOpened.new(data: { issue_id: cmd.id })
      end
    end

    def resolve(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Error unless issue.can_resolve?
        IssueResolved.new(data: { issue_id: cmd.id })
      end
    end

    def close(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Error unless issue.can_close?
        IssueClosed.new(data: { issue_id: cmd.id })
      end
    end

    def reopen(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Error unless issue.can_reopen?
        IssueReopened.new(data: { issue_id: cmd.id })
      end
    end

    def start(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Error unless issue.can_start?
        IssueProgressStarted.new(data: { issue_id: cmd.id })
      end
    end

    def stop(cmd)
      with_aggregate(cmd.id) do |issue|
        raise Error unless issue.can_stop?
        IssueProgressStopped.new(data: { issue_id: cmd.id })
      end
    end

    private

    def stream_name(id) = "Issue$#{id}"

    def with_aggregate(id)
      issue =
        IssueProjection.new(@event_store).call(Issue.initial, stream_name(id))

      @event_store.publish(yield(issue), stream_name: stream_name(id))
    end
  end
end
