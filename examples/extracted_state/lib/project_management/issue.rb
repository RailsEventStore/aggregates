# frozen_string_literal: true
module ProjectManagement
  class Issue
    InvalidTransition = Class.new(StandardError)

    attr_reader :changes

    def initialize(state)
      @changes = []
      @state = state
    end

    def open
      fail if @state.status
      changes << IssueOpened.new(data: { issue_id: @state.id })
    end

    def resolve
      fail unless %i[open in_progress reopened].include? @state.status
      changes << IssueResolved.new(data: { issue_id: @state.id })
    end

    def close
      fail unless %i[open in_progress resolved reopened].include? @state.status
      changes << IssueClosed.new(data: { issue_id: @state.id })
    end

    def reopen
      fail unless %i[resolved closed].include? @state.status
      changes << IssueReopened.new(data: { issue_id: @state.id })
    end

    def start
      fail unless %i[open reopened].include? @state.status
      changes << IssueProgressStarted.new(data: { issue_id: @state.id })
    end

    def stop
      fail unless %i[in_progress].include? @state.status
      changes << IssueProgressStopped.new(data: { issue_id: @state.id })
    end

    def fail = raise InvalidTransition
  end
end
