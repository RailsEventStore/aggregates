# frozen_string_literal: true

module ProjectManagement
  class Issue
    InvalidTransition = Class.new(StandardError)

    attr_reader :state

    def initialize(state)
      @state = state
    end

    def open
      fail if state.status

      state.status = "open"
      IssueOpened.new(data: { issue_id: state.id })
    end

    def resolve
      fail unless %w[open in_progress reopened].include? state.status

      state.status = "resolved"
      IssueResolved.new(data: { issue_id: state.id })
    end

    def close
      fail unless %w[open in_progress resolved reopened].include? state.status

      state.status = "closed"
      IssueClosed.new(data: { issue_id: state.id })
    end

    def reopen
      fail unless %w[resolved closed].include? state.status

      state.status = "reopened"
      IssueReopened.new(data: { issue_id: state.id })
    end

    def start
      fail unless %w[open reopened].include? state.status

      state.status = "in_progress"
      IssueProgressStarted.new(data: { issue_id: state.id })
    end

    def stop
      fail unless %w[in_progress].include? state.status

      state.status = "open"
      IssueProgressStopped.new(data: { issue_id: state.id })
    end

    def fail = raise InvalidTransition
  end
end
