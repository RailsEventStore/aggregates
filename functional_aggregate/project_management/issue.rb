module ProjectManagement
  module Issue
    InvalidTransition = Class.new(StandardError)

    class Create
      def call(state)
        raise InvalidTransition unless can_create?(state)
        IssueOpened.new(data: { issue_id: state.id })
      end

      private

      def can_create?(state)
        !state.open?
      end
    end

    class Resolve
      def call(state)
        raise InvalidTransition unless can_resolve?(state)
        IssueResolved.new(data: { issue_id: state.id })
      end

      private

      def can_resolve?(state)
        state.open? || state.reopened? || state.in_progress?
      end
    end

    class Close
      def call(state)
        raise InvalidTransition unless can_close?(state)
        IssueClosed.new(data: { issue_id: state.id })
      end

      private

      def can_close?(state)
        state.open? || state.in_progress? || state.reopened? || state.resolved?
      end
    end

    class Reopen
      def call(state)
        raise InvalidTransition unless can_reopen?(state)
        IssueReopened.new(data: { issue_id: state.id })
      end

      private

      def can_reopen?(state)
        state.closed? || state.resolved?
      end
    end

    class Stop
      def call(state)
        raise InvalidTransition unless can_stop?(state)
        IssueProgressStopped.new(data: { issue_id: state.id })
      end

      private

      def can_stop?(state)
        state.in_progress?
      end
    end

    class Start
      def call(state)
        raise InvalidTransition unless can_start?(state)
        IssueProgressStarted.new(data: { issue_id: state.id })
      end

      private

      def can_start?(state)
        state.open? || state.reopened?
      end
    end
  end
end