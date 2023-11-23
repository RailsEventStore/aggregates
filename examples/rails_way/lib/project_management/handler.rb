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
    end

    def create(cmd)
      create_issue(cmd.id) { IssueOpened.new(data: { issue_id: cmd.id }) }
    end

    def close(cmd)
      load_issue(cmd.id) do |issue|
        issue.close
        IssueClosed.new(data: { issue_id: cmd.id })
      end
    end

    def start(cmd)
      load_issue(cmd.id) do |issue|
        issue.start
        IssueProgressStarted.new(data: { issue_id: cmd.id })
      end
    end

    def stop(cmd)
      load_issue(cmd.id) do |issue|
        issue.stop
        IssueProgressStopped.new(data: { issue_id: cmd.id })
      end
    end

    def reopen(cmd)
      load_issue(cmd.id) do |issue|
        issue.reopen
        IssueReopened.new(data: { issue_id: cmd.id })
      end
    end

    def resolve(cmd)
      load_issue(cmd.id) do |issue|
        issue.resolve
        IssueResolved.new(data: { issue_id: cmd.id })
      end
    end

    private

    def stream_name(id) = "Issue$#{id}"

    def in_transaction(&) = ActiveRecord::Base.transaction(&)

    def create_issue(id)
      in_transaction do
        Issue.create!(uuid: id)
        @event_store.publish(yield, stream_name: stream_name(id))
      end
    rescue ActiveRecord::RecordNotUnique
      raise Error
    end

    def load_issue(id)
      in_transaction do
        issue = Issue.find_by!(uuid: id)
        @event_store.publish(yield(issue), stream_name: stream_name(id))
        issue.save!
      end
    rescue AASM::InvalidTransition, ActiveRecord::RecordNotFound
      raise Error
    end
  end
end
