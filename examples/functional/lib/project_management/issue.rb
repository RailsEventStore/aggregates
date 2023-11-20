module ProjectManagement
  module Issue
    InvalidTransition = Class.new(StandardError)

    def self.create(state)
      raise InvalidTransition unless state.initial?
      IssueOpened.new(data: { issue_id: state.id })
    end

    def self.resolve(state)
      unless state.open? || state.reopened? || state.in_progress?
        raise InvalidTransition
      end
      IssueResolved.new(data: { issue_id: state.id })
    end

    def self.close(state)
      unless state.open? || state.in_progress? || state.reopened? ||
               state.resolved?
        raise InvalidTransition
      end
      IssueClosed.new(data: { issue_id: state.id })
    end

    def self.reopen(state)
      raise InvalidTransition unless state.closed? || state.resolved?
      IssueReopened.new(data: { issue_id: state.id })
    end

    def self.stop(state)
      raise InvalidTransition unless state.in_progress?
      IssueProgressStopped.new(data: { issue_id: state.id })
    end

    def self.start(state)
      raise InvalidTransition unless state.open? || state.reopened?
      IssueProgressStarted.new(data: { issue_id: state.id })
    end
  end
end
