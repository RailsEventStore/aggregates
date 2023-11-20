module ProjectManagement
  class IssueState < Struct.new(:id, :status)
    def apply(event)
      case event
      when IssueOpened
        IssueState.new(id, :open)
      when IssueResolved
        IssueState.new(id, :resolved)
      when IssueClosed
        IssueState.new(id, :closed)
      when IssueReopened
        IssueState.new(id, :reopened)
      when IssueProgressStarted
        IssueState.new(id, :in_progress)
      when IssueProgressStopped
        IssueState.new(id, :open)
      end
    end
  end
end
