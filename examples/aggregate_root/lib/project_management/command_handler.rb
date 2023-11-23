module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @repository = AggregateRoot::Repository.new(event_store)
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

    def with_aggregate(id, &block)
      @repository.with_aggregate(Issue.new(id), "Issue$#{id}", &block)
    end
  end
end
