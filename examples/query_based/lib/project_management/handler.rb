module ProjectManagement
  class Handler
    def initialize(event_store)
      @event_store = event_store
    end

    def call(cmd)
      case cmd
      in CreateIssue[id:]
        create(id)
      in ResolveIssue[id:]
        resolve(id)
      in CloseIssue[id:]
        close(id)
      in ReopenIssue[id:]
        reopen(id)
      in StartIssueProgress[id:]
        start(id)
      in StopIssueProgress[id:]
        stop(id)
      end
    end

    def create(id)
      with_aggregate(id) do |issue|
        raise Error unless issue.can_create?
        IssueOpened.new(data: { issue_id: id })
      end
    end

    def resolve(id)
      with_aggregate(id) do |issue|
        raise Error unless issue.can_resolve?
        IssueResolved.new(data: { issue_id: id })
      end
    end

    def close(id)
      with_aggregate(id) do |issue|
        raise Error unless issue.can_close?
        IssueClosed.new(data: { issue_id: id })
      end
    end

    def reopen(id)
      with_aggregate(id) do |issue|
        raise Error unless issue.can_reopen?
        IssueReopened.new(data: { issue_id: id })
      end
    end

    def start(id)
      with_aggregate(id) do |issue|
        raise Error unless issue.can_start?
        IssueProgressStarted.new(data: { issue_id: id })
      end
    end

    def stop(id)
      with_aggregate(id) do |issue|
        raise Error unless issue.can_stop?
        IssueProgressStopped.new(data: { issue_id: id })
      end
    end

    private

    def stream_name(id) = "Issue$#{id}"

    def with_aggregate(id)
      issue =
        IssueProjection.new(@event_store).call(Issue.initial, stream_name(id))

      @event_store.append(yield(issue), stream_name: stream_name(id))
    end
  end
end
