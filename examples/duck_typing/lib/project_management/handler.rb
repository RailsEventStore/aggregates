# frozen_string_literal: true
module ProjectManagement
  class Handler
    def initialize(event_store)
      @repository = Repository.new(event_store)
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
    rescue NoMethodError
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

    def load_issue(id)
      issue = @repository.load(id, Issue.new)
      events = yield(issue)
      @repository.store(id, events)
    end
  end
end
