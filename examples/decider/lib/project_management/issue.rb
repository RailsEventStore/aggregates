module ProjectManagement
  module Issue
    InvalidTransition = Class.new(StandardError)
    State = Data.define(:id, :status)

    def self.decide(command, state)
      case command
      when CreateIssue
        if state.status
          InvalidTransition.new
        else
          IssueOpened.new(data: { issue_id: state.id })
        end
      when ResolveIssue
        if %i[open in_progress reopened].include? state.status
          IssueResolved.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      when CloseIssue
        if %i[open in_progress resolved reopened].include? state.status
          IssueClosed.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      when ReopenIssue
        if %i[resolved closed].include? state.status
          IssueReopened.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      when StartIssueProgress
        if %i[open reopened].include? state.status
          IssueProgressStarted.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      when StopIssueProgress
        if %i[in_progress].include? state.status
          IssueProgressStopped.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      end
    end

    def self.evolve(state, event)
      case event
      when IssueOpened
        state.with(status: :open)
      when IssueResolved
        state.with(status: :resolved)
      when IssueClosed
        state.with(status: :closed)
      when IssueReopened
        state.with(status: :reopened)
      when IssueProgressStarted
        state.with(status: :in_progress)
      when IssueProgressStopped
        state.with(status: :open)
      end
    end

    def self.initial_state(id)
      State.new(id: id, status: nil)
    end
  end
end