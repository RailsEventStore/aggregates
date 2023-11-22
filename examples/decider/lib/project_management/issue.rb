module ProjectManagement
  module Issue
    InvalidTransition = Class.new(StandardError)
    State = Data.define(:id, :status)

    class << self
      def decide(command, state)
        case command
        when CreateIssue
          open(state)
        when ResolveIssue
          resolve(state)
        when CloseIssue
          close(state)
        when ReopenIssue
          reopen(state)
        when StartIssueProgress
          start(state)
        when StopIssueProgress
          stop(state)
        end
      end

      def evolve(state, event)
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

      def initial_state(id)
        State.new(id: id, status: nil)
      end

      private

      def open(state)
        if state.status
          InvalidTransition.new
        else
          IssueOpened.new(data: { issue_id: state.id })
        end
      end

      def resolve(state)
        if %i[open in_progress reopened].include? state.status
          IssueResolved.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      end

      def close(state)
        if %i[open in_progress resolved reopened].include? state.status
          IssueClosed.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      end

      def reopen(state)
        if %i[resolved closed].include? state.status
          IssueReopened.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      end

      def stop(state)
        if %i[in_progress].include? state.status
          IssueProgressStopped.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      end

      def start(state)
        if %i[open reopened].include? state.status
          IssueProgressStarted.new(data: { issue_id: state.id })
        else
          InvalidTransition.new
        end
      end
    end
  end
end
