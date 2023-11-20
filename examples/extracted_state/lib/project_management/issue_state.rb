module ProjectManagement
  class IssueState < Struct.new(:id, :status)
    def initial? = status.nil?
    def open? = status == :open
    def closed? = status == :closed
    def in_progress? = status == :in_progress
    def reopened? = status == :reopened
    def resolved? = status == :resolved

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
