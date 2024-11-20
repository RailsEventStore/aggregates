# frozen_string_literal: true

module ProjectManagement
  class IssueState < Struct.new(:id, :status)
    include AggregateState


    on IssueOpened do |ev|
      self.id = ev.data.fetch(:issue_id)
      self.status = :open
    end

    on IssueResolved do |_ev|
      self.status = :resolved
    end

    on IssueClosed do |_ev|
      self.status = :closed
    end

    on IssueReopened do |_ev|
      self.status = :reopened
    end

    on IssueProgressStarted do |_ev|
      self.status = :in_progress
    end

    on IssueProgressStopped do |_ev|
      self.status = :open
    end
  end
end
