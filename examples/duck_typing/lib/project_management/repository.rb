module ProjectManagement
  class Repository
    def initialize(event_store)
      @event_store = event_store
    end

    def load(id, initial_issue)
      @event_store
        .read
        .stream(stream_name(id))
        .reduce(initial_issue) do |issue, event|
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
    end

    def store(id, events)
      @event_store.append(events, stream_name: stream_name(id))
    end

    private

    def stream_name(id) = "Issue$#{id}"
  end
end
