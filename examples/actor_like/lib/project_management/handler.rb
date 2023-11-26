module ProjectManagement
  class Handler
    def initialize(event_store)
      @repository = AggregateRepository.new(event_store)
    end

    def call(cmd)
      case cmd
      when CreateIssue
        create(cmd)
      when ResolveIssue
        resolve(cmd)
      when CloseIssue
        close(cmd)
      when ReopenIssue
        reopen(cmd)
      when StartIssueProgress
        start(cmd)
      when StopIssueProgress
        stop(cmd)
      end
    rescue Issue::InvalidTransition
      raise Error
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

    def stream_name(id) = "Issue$#{id}"

    def with_issue(id)
      @repository.with_state(IssueState.new, stream_name(id)) do |state, store|
        yield Issue.new(state).link(store)
      end
    end
  end
end
