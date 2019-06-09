module ProjectManagement

  class Issue
    class InvalidTransition < StandardError; end
  end

  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
    end

    def create(cmd)
      load_issue(cmd.id) do |issue|
        issue.open(title: SecureRandom.hex(4))
        IssueOpened.new(data: {issue_id: cmd.id, title: SecureRandom.hex(6)})
      end
    end

    def close(cmd)
      load_issue(cmd.id) do |issue|
        issue.close
        IssueClosed.new(data: {issue_id: cmd.id})
      end
    end

    def start(cmd)
      load_issue(cmd.id) do |issue|
        issue.start
        IssueProgressStarted.new(data: {issue_id: cmd.id})
      end
    end

    def stop(cmd)
      load_issue(cmd.id) do |issue|
        issue.stop
        IssueProgressStopped.new(data: {issue_id: cmd.id})
      end
    end

    def reopen(cmd)
      load_issue(cmd.id) do |issue|
        issue.reopen
        IssueReopened.new(data: {issue_id: cmd.id})
      end
    end

    def resolve(cmd)
      load_issue(cmd.id) do |issue|
        issue.resolve
        IssueResolved.new(data: {issue_id: cmd.id})
      end
    end

    private

    def stream_name(id)
      "Issue$#{id}"
    end

    def load_issue(id)
      version = -1
      issue = Issue.create(id: id)
      @event_store.read.stream(stream_name(id)).each do |event|
        case event
        when IssueOpened
          issue = issue.open(title: event.data[:title])
        when IssueProgressStarted
          issue = issue.start
        when IssueProgressStopped
          issue = issue.stop
        when IssueResolved
          issue = issue.resolve
        when IssueReopened
          issue = issue.reopen
        when IssueClosed
          issue = issue.close
        end
        version += 1
      end
      events = yield issue
      publish(events, id, version)
    rescue NoMethodError
      raise Issue::InvalidTransition
    end

    def publish(events, id, version)
      @event_store.publish(
        events,
        stream_name: stream_name(id),
        expected_version: version
      )
    end
  end
end