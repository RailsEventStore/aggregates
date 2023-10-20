require "aggregate_root"

module ProjectManagement
  class Issue
    include AggregateRoot

    InvalidTransition = Class.new(StandardError)

    def initialize(id)
      @id = id
    end

    def open
      fail unless initial?
      apply(IssueOpened.new(data: { issue_id: @id }))
    end

    def resolve
      fail unless open? || reopened? || in_progress?
      apply(IssueResolved.new(data: { issue_id: @id }))
    end

    def close
      fail unless open? || in_progress? || reopened? || resolved?
      apply(IssueClosed.new(data: { issue_id: @id }))
    end

    def reopen
      fail unless closed? || resolved?
      apply(IssueReopened.new(data: { issue_id: @id }))
    end

    def start
      fail unless open? || reopened?
      apply(IssueProgressStarted.new(data: { issue_id: @id }))
    end

    def stop
      fail unless in_progress?
      apply(IssueProgressStopped.new(data: { issue_id: @id }))
    end

    private

    def fail = raise InvalidTransition
    def initial? = @status.nil?
    def open? = @status == :open
    def closed? = @status == :closed
    def in_progress? = @status == :in_progress
    def reopened? = @status == :reopened
    def resolved? = @status == :resolved

    on(IssueOpened) { |event| @status = :open }
    on(IssueResolved) { |event| @status = :resolved }
    on(IssueClosed) { |event| @status = :closed }
    on(IssueReopened) { |event| @status = :reopened }
    on(IssueProgressStarted) { |event| @status = :in_progress }
    on(IssueProgressStopped) { |event| @status = :open }
  end
end
