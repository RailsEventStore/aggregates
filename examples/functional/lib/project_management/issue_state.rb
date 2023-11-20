module ProjectManagement
  class IssueState < Struct.new(:id, :status)
    def initial?
      status.nil?
    end
    def open?
      status == :open
    end

    def closed?
      status == :closed
    end

    def in_progress?
      status == :in_progress
    end

    def reopened?
      status == :reopened
    end

    def resolved?
      status == :resolved
    end

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
