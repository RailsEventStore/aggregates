module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @repo = AggregateRepository.new(event_store)
    end

    def create(cmd)
      with_issue(cmd.id) { |issue| issue.create(cmd.id) }
    end

    def resolve(cmd)
      with_issue(cmd.id) { |issue| issue.resolve }
    end

    def close(cmd)
      with_issue(cmd.id) { |issue| issue.close }
    end

    def reopen(cmd)
      with_issue(cmd.id) { |issue| issue.reopen }
    end

    def start(cmd)
      with_issue(cmd.id) { |issue| issue.start }
    end

    def stop(cmd)
      with_issue(cmd.id) { |issue| issue.stop }
    end

    private

    attr_reader :repo

    def with_issue(id)
      stream = "Issue$#{id}"
      repo.with_state(IssueState.new, stream) { |state, store| yield Issue.new(state).link(store) }
    rescue Issue::InvalidTransition
      raise Command::Rejected
    end
  end
end
