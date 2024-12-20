# frozen_string_literal: true

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
