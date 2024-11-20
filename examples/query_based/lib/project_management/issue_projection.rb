# frozen_string_literal: true
module ProjectManagement
  class IssueProjection
    def self.call(query, initial_issue)
      query
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
