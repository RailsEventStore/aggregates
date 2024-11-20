# frozen_string_literal: true

module ProjectManagement
  class IssueState < Struct.new(:id, :status)
    include AggregateState

    private

    on IssueOpened do |ev|
      self.id = ev.data.fetch(:issue_id)
      self.status = :open
    end

    on IssueResolved do |ev|
      self.status = :resolved
    end

    on IssueClosed do |ev|
      self.status = :closed
    end

    on IssueReopened do |ev|
      self.status = :reopened
    end

    on IssueProgressStarted do |ev|
      self.status = :in_progress
    end

    on IssueProgressStopped do |ev|
      self.status = :open
    end
  end
end
