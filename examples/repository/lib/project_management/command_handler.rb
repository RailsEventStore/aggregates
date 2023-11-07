module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @repository = Repository.new(event_store)
    end

    def create(cmd)
      with_aggregate(cmd.id, &:create)
    end

    def resolve(cmd)
      with_aggregate(cmd.id, &:resolve)
    end

    def close(cmd)
      with_aggregate(cmd.id, &:close)
    end

    def reopen(cmd)
      with_aggregate(cmd.id, &:reopen)
    end

    def start(cmd)
      with_aggregate(cmd.id, &:start)
    end

    def stop(cmd)
      with_aggregate(cmd.id, &:stop)
    end

    private

    attr_reader :repository

    def with_aggregate(id)
      events, current_version = repository.load(id)
      issue = Issue.load(id, events)
      yield issue
      repository.save(id, current_version, issue.changes)
    rescue Issue::InvalidTransition
      raise Error
    end
  end
end
