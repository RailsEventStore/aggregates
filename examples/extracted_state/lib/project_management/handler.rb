module ProjectManagement
  class Handler
    def initialize(event_store)
      @repository = Repository.new(event_store)
    end

    def call(cmd)
      case cmd
      in CreateIssue[id:]
        create(id)
      in ResolveIssue[id:]
        resolve(id)
      in CloseIssue[id:]
        close(id)
      in ReopenIssue[id:]
        reopen(id)
      in StartIssueProgress[id:]
        start(id)
      in StopIssueProgress[id:]
        stop(id)
      end
    rescue Issue::InvalidTransition
      raise Error
    end

    def create(id) = with_aggregate(id) { |issue| issue.open }
    def resolve(id) = with_aggregate(id) { |issue| issue.resolve }
    def close(id) = with_aggregate(id) { |issue| issue.close }
    def reopen(id) = with_aggregate(id) { |issue| issue.reopen }
    def start(id) = with_aggregate(id) { |issue| issue.start }
    def stop(id) = with_aggregate(id) { |issue| issue.stop }

    private

    def with_aggregate(id)
      state = @repository.load(id, IssueState.initial(id))
      issue = Issue.new(state)
      yield issue

      @repository.store(id, issue.changes)
    end
  end
end
