module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
    end

    def create(cmd)
      load_issue(cmd.id) do |issue|
        issue.open
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

    def load_issue(id)
      issue, version =
        @event_store
          .read
          .stream(stream_name(id))
          .reduce([Issue.new, -1]) do |(issue, version), event|
            new_issue =
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
            [new_issue, version + 1]
          end

      @event_store.publish(yield(issue), stream_name: stream_name(id), expected_version: version)
    rescue Issue::InvalidTransition
      raise Error
    end
  end
end
