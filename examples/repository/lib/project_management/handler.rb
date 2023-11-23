module ProjectManagement
  class Handler
    def initialize(event_store)
      @repository = Repository.new(event_store)
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
      events = repository.load(id)
      issue = Issue.load(id, events)
      yield issue
      repository.save(id, issue.changes)
    end
  end
end
