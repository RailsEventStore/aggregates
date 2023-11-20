module ProjectManagement
  module Issue
    InvalidTransition = Class.new(StandardError)

    def self.open(state)
      if state.status
        InvalidTransition.new
      else
        IssueOpened.new(data: { issue_id: state.id })
      end
    end

    def self.resolve(state)
      if %i[open in_progress reopened].include? state.status
        IssueResolved.new(data: { issue_id: state.id })
      else
        InvalidTransition.new
      end
    end

    def self.close(state)
      if %i[open in_progress resolved reopened].include? state.status
        IssueClosed.new(data: { issue_id: state.id })
      else
        InvalidTransition.new
      end
    end

    def self.reopen(state)
      if %i[resolved closed].include? state.status
        IssueReopened.new(data: { issue_id: state.id })
      else
        InvalidTransition.new
      end
    end

    def self.stop(state)
      if %i[in_progress].include? state.status
        IssueProgressStopped.new(data: { issue_id: state.id })
      else
        InvalidTransition.new
      end
    end

    def self.start(state)
      if %i[open reopened].include? state.status
        IssueProgressStarted.new(data: { issue_id: state.id })
      else
        InvalidTransition.new
      end
    end
  end
end
