module ProjectManagement
  class IssueProjection
    def initialize(event_store)
      @event_store = event_store
    end

    def call(issue, stream_name)
      @event_store
        .read
        .stream(stream_name)
        .reduce([issue, -1]) do |(issue, version), event|
          new_issue =
            case event
            when IssueOpened
              issue.open
            when IssueReopened
              issue.reopen
            when IssueClosed
              issue.close
            when IssueResolved
              issue.resolve
            when IssueProgressStarted
              issue.start
            when IssueProgressStopped
              issue.stop
            end

          [new_issue, version + 1]
        end
    end
  end
end
