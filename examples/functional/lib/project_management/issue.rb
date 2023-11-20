module ProjectManagement
  module Issue
    InvalidTransition = Class.new(StandardError)

    def self.create(state)
      raise InvalidTransition if state.status
      IssueOpened.new(data: { issue_id: state.id })
    end

    def self.resolve(state)
      unless %i[open in_progress reopened].include? state.status
        raise InvalidTransition
      end
      IssueResolved.new(data: { issue_id: state.id })
    end

    def self.close(state)
      unless %i[open in_progress resolved reopened].include? state.status
        raise InvalidTransition
      end
      IssueClosed.new(data: { issue_id: state.id })
    end

    def self.reopen(state)
      raise InvalidTransition unless %i[resolved closed].include? state.status
      IssueReopened.new(data: { issue_id: state.id })
    end

    def self.stop(state)
      raise InvalidTransition unless %i[in_progress].include? state.status
      IssueProgressStopped.new(data: { issue_id: state.id })
    end

    def self.start(state)
      raise InvalidTransition unless %i[open reopened].include? state.status
      IssueProgressStarted.new(data: { issue_id: state.id })
    end
  end
end
