module ProjectManagement
  class Handler
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
    rescue Issue::InvalidTransition
      raise Error
    end

    def create(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.create
        IssueOpened.new(data: { issue_id: cmd.id })
      end
    end

    def resolve(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.resolve
        IssueResolved.new(data: { issue_id: cmd.id })
      end
    end

    def close(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.close
        IssueClosed.new(data: { issue_id: cmd.id })
      end
    end

    def reopen(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.reopen
        IssueReopened.new(data: { issue_id: cmd.id })
      end
    end

    def start(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.start
        IssueProgressStarted.new(data: { issue_id: cmd.id })
      end
    end

    def stop(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.stop
        IssueProgressStopped.new(data: { issue_id: cmd.id })
      end
    end

    private

    attr_reader :event_store

    def stream_name(id)
      "Issue$#{id}"
    end

    def with_aggregate(id)
      state = IssueProjection.new(event_store).call(stream_name(id))
      event = yield Issue.new(state.status)
      event_store.append(event, stream_name: stream_name(id))
    end
  end
end
