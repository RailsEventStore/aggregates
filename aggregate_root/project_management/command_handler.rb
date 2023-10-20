module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def create(cmd)
      with_aggregate(cmd.id) { |issue| issue.open}
    end

    def resolve(cmd)
      with_aggregate(cmd.id) { |issue| issue.resolve }
    end

    def close(cmd)
      with_aggregate(cmd.id) { |issue| issue.close }
    end

    def reopen(cmd)
      with_aggregate(cmd.id) { |issue| issue.reopen }
    end

    def start(cmd)
      with_aggregate(cmd.id) { |issue| issue.start }
    end

    def stop(cmd)
      with_aggregate(cmd.id) { |issue| issue.stop }
    end

    private

    attr_reader :repository

    def stream_name(id)
      "Issue$#{id}"
    end

    def with_aggregate(id, &block)
      repository.with_aggregate(Issue.new(id), stream_name(id), &block)
    end
  end
end
