module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @repository = AggregateRoot::Repository.new(event_store)
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
    rescue Issue::InvalidTransition
      raise Command::Rejected
    end
  end
end
