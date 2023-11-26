module ProjectManagement
  class Handler
    def initialize(event_store)
      @event_store = event_store
    end

    def call(cmd)
      case cmd
      when CreateIssue
        create(cmd.id)
      when ResolveIssue
        resolve(cmd.id)
      when CloseIssue
        close(cmd.id)
      when ReopenIssue
        reopen(cmd.id)
      when StartIssueProgress
        start(cmd.id)
      when StopIssueProgress
        stop(cmd.id)
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

    def stream_name(id) = "Issue$#{id}"

    def with_aggregate(id)
      repository = Issue::Repository.new(id)
      issue = Issue.new(repository.load)

      @event_store.append(yield(issue), stream_name: stream_name(id))
      repository.store(issue.state)
    end
  end
end
