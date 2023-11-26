module ProjectManagement
  class Handler
    def initialize(event_store)
      @event_store = event_store
    end

    def call(cmd)
      case cmd
      when CreateIssue
        create(cmd.id)
      when ResolveIssue
        resolve(cmd.id)
      when CloseIssue
        close(cmd.id)
      when ReopenIssue
        reopen(cmd.id)
      when StartIssueProgress
        start(cmd.id)
      when StopIssueProgress
        stop(cmd.id)
      end
    rescue Issue::InvalidTransition
      raise Error
    end

    def create(id)
      with_aggregate(id) do |issue|
        issue.create
        IssueOpened.new(data: { issue_id: id })
      end
    end

    def resolve(id)
      with_aggregate(id) do |issue|
        issue.resolve
        IssueResolved.new(data: { issue_id: id })
      end
    end

    def close(id)
      with_aggregate(id) do |issue|
        issue.close
        IssueClosed.new(data: { issue_id: id })
      end
    end

    def reopen(id)
      with_aggregate(id) do |issue|
        issue.reopen
        IssueReopened.new(data: { issue_id: id })
      end
    end

    def start(id)
      with_aggregate(id) do |issue|
        issue.start
        IssueProgressStarted.new(data: { issue_id: id })
      end
    end

    def stop(id)
      with_aggregate(id) do |issue|
        issue.stop
        IssueProgressStopped.new(data: { issue_id: id })
      end
    end

    private

    def stream_name(id) = "Issue$#{id}"

    def with_aggregate(id)
      state = IssueProjection.new(@event_store).call(stream_name(id))
      event = yield Issue.new(state.status)
      @event_store.append(event, stream_name: stream_name(id))
    end
  end
end
