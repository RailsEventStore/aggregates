module ProjectManagement
  class Issue
    InvalidTransition = Class.new(StandardError)

    State = Data.define(:id, :status)
    private_constant :State

    def initialize(id)
      @state = initial_state(id)
    end

    def decide(command)
      case command
      when CreateIssue
        open
      when ResolveIssue
        resolve
      when CloseIssue
        close
      when ReopenIssue
        reopen
      when StartIssueProgress
        start
      when StopIssueProgress
        stop
      end
    end

    def evolve(event)
      @state =
        case event
        when IssueOpened
          @state.with(status: :open)
        when IssueResolved
          @state.with(status: :resolved)
        when IssueClosed
          @state.with(status: :closed)
        when IssueReopened
          @state.with(status: :reopened)
        when IssueProgressStarted
          @state.with(status: :in_progress)
        when IssueProgressStopped
          @state.with(status: :open)
        end
    end

    private

    def open
      fail if @state.status
      IssueOpened.new(data: { issue_id: @state.id })
    end

    def resolve
      fail unless %i[open in_progress reopened].include? @state.status
      IssueResolved.new(data: { issue_id: @state.id })
    end

    def close
      fail unless %i[open in_progress resolved reopened].include? @state.status
      IssueClosed.new(data: { issue_id: @state.id })
    end

    def reopen
      fail unless %i[resolved closed].include? @state.status
      IssueReopened.new(data: { issue_id: @state.id })
    end

    def start
      fail unless %i[open reopened].include? @state.status
      IssueProgressStarted.new(data: { issue_id: @state.id })
    end

    def stop
      fail unless %i[in_progress].include? @state.status
      IssueProgressStopped.new(data: { issue_id: @state.id })
    end

    def fail = raise InvalidTransition

    def initial_state(id) = State.new(id: id, status: nil)
  end
end
