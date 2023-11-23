module ProjectManagement
  class IssueProjection
    def initialize(event_store)
      @event_store = event_store
    end

    def call(initial_issue, stream_name)
      @event_store
        .read
        .stream(stream_name)
        .reduce(initial_issue) do |issue, event|
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
        end
    end
  end
end
