module ProjectManagement
  class Handler
    def initialize(event_store)
      @event_store = event_store
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

    def create(cmd) = with_aggregate(cmd.id) { |issue| issue.open }
    def resolve(cmd) = with_aggregate(cmd.id) { |issue| issue.resolve }
    def close(cmd) = with_aggregate(cmd.id) { |issue| issue.close }
    def reopen(cmd) = with_aggregate(cmd.id) { |issue| issue.reopen }
    def start(cmd) = with_aggregate(cmd.id) { |issue| issue.start }
    def stop(cmd) = with_aggregate(cmd.id) { |issue| issue.stop }

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
