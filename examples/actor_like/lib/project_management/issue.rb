# frozen_string_literal: true
module ProjectManagement
  class Issue
    include AggregateRoot
    InvalidTransition = Class.new(StandardError)

    def create(id)
      invalid_transition unless can_create?
      apply(IssueOpened.new(data: { issue_id: id }))
    end

    def resolve
      invalid_transition unless can_resolve?
      apply(IssueResolved.new(data: { issue_id: state.id }))
    end

    def close
      invalid_transition unless can_close?
      apply(IssueClosed.new(data: { issue_id: state.id }))
    end

    def reopen
      invalid_transition unless can_reopen?
      apply(IssueReopened.new(data: { issue_id: state.id }))
    end

    def start
      invalid_transition unless can_start?
      apply(IssueProgressStarted.new(data: { issue_id: state.id }))
    end

    def stop
      invalid_transition unless can_stop?
      apply(IssueProgressStopped.new(data: { issue_id: state.id }))
    end

    private

    def invalid_transition
      raise InvalidTransition
    end

    def open?
      state.status == :open
    end

    def closed?
      state.status == :closed
    end

    def in_progress?
      state.status == :in_progress
    end

    def reopened?
      state.status == :reopened
    end

    def resolved?
      state.status == :resolved
    end

    def can_reopen?
      closed? || resolved?
    end

    def can_start?
      open? || reopened?
    end

    def can_stop?
      in_progress?
    end

    def can_close?
      open? || in_progress? || reopened? || resolved?
    end

    def can_resolve?
      open? || reopened? || in_progress?
    end

    def can_create?
      state.status.nil?
    end
  end
end
