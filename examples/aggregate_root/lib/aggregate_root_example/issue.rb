module AggregateRootExample
  class Issue
    include ::AggregateRoot

    InvalidTransition = Class.new(StandardError)

    def initialize(id)
      @id = id
    end

    def open
      fail if @status
      apply(PM::IssueOpened.new(data: { issue_id: @id }))
    end

    def resolve
      fail unless %i[open in_progress reopened].include? @status
      apply(PM::IssueResolved.new(data: { issue_id: @id }))
    end

    def close
      fail unless %i[open in_progress resolved reopened].include? @status
      apply(PM::IssueClosed.new(data: { issue_id: @id }))
    end

    def reopen
      fail unless %i[resolved closed].include? @status
      apply(PM::IssueReopened.new(data: { issue_id: @id }))
    end

    def start
      fail unless %i[open reopened].include? @status
      apply(PM::IssueProgressStarted.new(data: { issue_id: @id }))
    end

    def stop
      fail unless %i[in_progress].include? @status
      apply(PM::IssueProgressStopped.new(data: { issue_id: @id }))
    end

    private

    def fail = raise InvalidTransition

    on(PM::IssueOpened) { |event| @status = :open }
    on(PM::IssueResolved) { |event| @status = :resolved }
    on(PM::IssueClosed) { |event| @status = :closed }
    on(PM::IssueReopened) { |event| @status = :reopened }
    on(PM::IssueProgressStarted) { |event| @status = :in_progress }
    on(PM::IssueProgressStopped) { |event| @status = :open }
  end
end
