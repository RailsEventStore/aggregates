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
    rescue AASM::InvalidTransition,
           ActiveRecord::RecordNotFound,
           ActiveRecord::RecordNotUnique
      raise Error
    end

    def create(id)
      create_issue(id) { IssueOpened.new(data: { issue_id: id }) }
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

    def stream_name(id) = "Issue$#{id}"

    def create_issue(id)
      Issue.create!(uuid: id)
      @event_store.append(yield, stream_name: stream_name(id))
    end

    def load_issue(id)
      issue = Issue.find_by!(uuid: id)
      @event_store.append(yield(issue), stream_name: stream_name(id))
      issue.save!
    end
  end
end
