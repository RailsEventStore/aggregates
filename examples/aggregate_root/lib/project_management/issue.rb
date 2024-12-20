# frozen_string_literal: true

module ProjectManagement
  class Issue
    include AggregateRoot

    InvalidTransition = Class.new(StandardError)

    def initialize(id)
      @id = id
    end

    def open
      fail if @status

      apply(IssueOpened.new(data: { issue_id: @id }))
    end

    def resolve
      fail unless %i[open in_progress reopened].include? @status

      apply(IssueResolved.new(data: { issue_id: @id }))
    end

    def close
      fail unless %i[open in_progress resolved reopened].include? @status

      apply(IssueClosed.new(data: { issue_id: @id }))
    end

    def reopen
      fail unless %i[resolved closed].include? @status

      apply(IssueReopened.new(data: { issue_id: @id }))
    end

    def start
      fail unless %i[open reopened].include? @status

      apply(IssueProgressStarted.new(data: { issue_id: @id }))
    end

    def stop
      fail unless %i[in_progress].include? @status

      apply(IssueProgressStopped.new(data: { issue_id: @id }))
    end

    private

    def fail = raise InvalidTransition

    on(IssueOpened) { |_event| @status = :open }
    on(IssueResolved) { |_event| @status = :resolved }
    on(IssueClosed) { |_event| @status = :closed }
    on(IssueReopened) { |_event| @status = :reopened }
    on(IssueProgressStarted) { |_event| @status = :in_progress }
    on(IssueProgressStopped) { |_event| @status = :open }
  end
end
