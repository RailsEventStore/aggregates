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
      load_issue(id) do |issue|
        issue.open
        IssueOpened.new(data: { issue_id: id })
      end
    end

    def close(id)
      load_issue(id) do |issue|
        issue.close
        IssueClosed.new(data: { issue_id: id })
      end
    end

    def start(id)
      load_issue(id) do |issue|
        issue.start
        IssueProgressStarted.new(data: { issue_id: id })
      end
    end

    def stop(id)
      load_issue(id) do |issue|
        issue.stop
        IssueProgressStopped.new(data: { issue_id: id })
      end
    end

    def reopen(id)
      load_issue(id) do |issue|
        issue.reopen
        IssueReopened.new(data: { issue_id: id })
      end
    end

    def resolve(id)
      load_issue(id) do |issue|
        issue.resolve
        IssueResolved.new(data: { issue_id: id })
      end
    end

    private

    def stream_name(id)
      "Issue$#{id}"
    end

    def load_issue(id)
      issue =
        @event_store
        .read
        .stream(stream_name(id))
        .reduce(Issue.new) do |issue, event|
          case event
          when IssueOpened
            issue.open
          when IssueProgressStarted
            issue.start
          when IssueProgressStopped
            issue.stop
          when IssueResolved
            issue.resolve
          when IssueReopened
            issue.reopen
          when IssueClosed
            issue.close
          end
        end

      @event_store.append(yield(issue), stream_name: stream_name(id))
    end
  end
end
