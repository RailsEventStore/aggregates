# frozen_string_literal: true

module ProjectManagement
  IssueState =
    Data.define(:id, :status) do
      def self.initial(id)
        new(id: id, status: nil)
      end

      def apply(event)
        case event
        when IssueOpened
          with(status: :open)
        when IssueResolved
          with(status: :resolved)
        when IssueClosed
          with(status: :closed)
        when IssueReopened
          with(status: :reopened)
        when IssueProgressStarted
          with(status: :in_progress)
        when IssueProgressStopped
          with(status: :open)
        end
      end
    end
end
