# frozen_string_literal: true
module ProjectManagement
  module Issue
    InvalidTransition = Class.new(StandardError)
    State = Data.define(:id, :status)

    class << self
      def decide(command, state)
        case [command, state]
        in [CreateIssue, State(id:, status: nil)]
          [IssueOpened.new(data: { issue_id: id })]
        in [ResolveIssue, State(id:, status: :open | :in_progress | :reopened)]
          [IssueResolved.new(data: { issue_id: id })]
        in [CloseIssue, State(id:, status: :open | :in_progress | :resolved | :reopened)]
          [IssueClosed.new(data: { issue_id: id })]
        in [ReopenIssue, State(id:, status: :resolved | :closed)]
          [IssueReopened.new(data: { issue_id: id })]
        in [StartIssueProgress, State(id:, status: :open | :reopened)]
          [IssueProgressStarted.new(data: { issue_id: id })]
        in [StopIssueProgress, State(id:, status: :in_progress)]
          [IssueProgressStopped.new(data: { issue_id: id })]
        else
          [InvalidTransition.new]
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
    end
  end
end
