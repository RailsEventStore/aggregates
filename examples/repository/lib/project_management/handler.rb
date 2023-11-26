module ProjectManagement
  class Handler
    def initialize(event_store)
      @repository = Repository.new(event_store)
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

    def create(id)
      with_aggregate(id, &:create)
    end

    def resolve(id)
      with_aggregate(id, &:resolve)
    end

    def close(id)
      with_aggregate(id, &:close)
    end

    def reopen(id)
      with_aggregate(id, &:reopen)
    end

    def start(id)
      with_aggregate(id, &:start)
    end

    def stop(id)
      with_aggregate(id, &:stop)
    end

    private

    def with_aggregate(id)
      events = @repository.load(id)
      issue = Issue.load(id, events)
      yield issue
      @repository.save(id, issue.changes)
    end
  end
end
