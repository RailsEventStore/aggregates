module ProjectManagement
  class IssueState < Struct.new(:id, :status)
    def open?
      status.equal?(:open)
    end

    def closed?
      status.equal?(:closed)
    end

    def in_progress?
      status.equal?(:in_progress)
    end

    def reopened?
      status.equal?(:reopened)
    end

    def resolved?
      status.equal?(:resolved)
    end

    def apply(event)
      case event
      when IssueOpened
        self.status = :open
      when IssueResolved
        self.status = :resolved
      when IssueClosed
        self.status = :closed
      when IssueReopened
        self.status = :reopened
      when IssueProgressStarted
        self.status = :in_progress
      when IssueProgressStopped
        self.status = :open
      end
    end
  end
end
