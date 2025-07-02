# frozen_string_literal: true

require "decider"

module ProjectManagement
  module Issue
    IssueOpened = Data.define(:issue_id)
    IssueResolved = Data.define(:issue_id)
    IssueClosed = Data.define(:issue_id)
    IssueReopened = Data.define(:issue_id)
    IssueProgressStarted = Data.define(:issue_id)
    IssueProgressStopped = Data.define(:issue_id)
    InvalidTransition = Data.define

    Decider = Decider.define do
      initial_state :none

      decide CreateIssue, :none do
        emit IssueOpened.new(issue_id: command.id)
      end

      decide proc { [command, state] in [ResolveIssue, :open | :in_progress | :reopened] } do
        emit IssueResolved.new(issue_id: command.id)
      end

      decide proc { [command, state] in [CloseIssue, :open | :in_progress | :resolved | :reopened] } do
        emit IssueClosed.new(issue_id: command.id)
      end

      decide proc { [command, state] in [ReopenIssue, :resolved | :closed] } do
        emit IssueReopened.new(issue_id: command.id)
      end

      decide proc { [command, state] in [StartIssueProgress, :open | :reopened] } do
        emit IssueProgressStarted.new(issue_id: command.id)
      end

      decide StopIssueProgress, :in_progress do
        emit IssueProgressStopped.new(issue_id: command.id)
      end

      decide proc { true } do
        emit InvalidTransition.new
      end

      evolve IssueOpened do
        :open
      end

      evolve IssueResolved do
        :resolved
      end

      evolve IssueClosed do
        :closed
      end

      evolve IssueReopened do
        :reopened
      end

      evolve IssueProgressStarted do
        :in_progress
      end

      evolve IssueProgressStopped do
        :open
      end
    end
  end
end
