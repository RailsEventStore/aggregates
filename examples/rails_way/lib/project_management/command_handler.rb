module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
    end

    def create(cmd)
      create_issue(cmd.id) do
        IssueOpened.new(data: { issue_id: cmd.id })
      end
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

    def stream_name(id)
      "Issue$#{id}"
    end

    def create_issue(id)
      Issue.create!(uuid: id)
      events = yield
      @event_store.publish(events, stream_name: stream_name(id))
    rescue ActiveRecord::RecordNotUnique
      raise Issue::InvalidTransition
    end

    def load_issue(id)
      issue = Issue.find_by!(uuid: id)
      events = yield issue
      issue.save!
      @event_store.publish(events, stream_name: stream_name(id))
    rescue AASM::InvalidTransition, ActiveRecord::RecordNotFound
      raise Issue::InvalidTransition
    end
  end
end
