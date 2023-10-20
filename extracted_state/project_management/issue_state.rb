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
