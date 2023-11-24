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

    private

    def create(cmd)
      @repository.with_aggregate(
        Issue.new(cmd.id),
        stream_name(cmd.id)
      ) { |issue| issue.open }
    end

    def resolve(cmd)
      issue = Issue.new(cmd.id)
      @repository.load(issue, stream_name(cmd.id))
      issue.resolve
      @repository.store(issue, stream_name(cmd.id))
    end

    def close(cmd)
      issue = Issue.new(cmd.id)
      @repository.load(issue, stream_name(cmd.id))
      issue.close
      @repository.store(issue, stream_name(cmd.id))
    end

    def reopen(cmd)
      issue = Issue.new(cmd.id)
      @repository.load(issue, stream_name(cmd.id))
      issue.reopen
      @repository.store(issue, stream_name(cmd.id))
    end

    def start(cmd)
      issue = Issue.new(cmd.id)
      @repository.load(issue, stream_name(cmd.id))
      issue.start
      @repository.store(issue, stream_name(cmd.id))
    end

    def stop(cmd)
      issue = Issue.new(cmd.id)
      @repository.load(issue, stream_name(cmd.id))
      issue.stop
      @repository.store(issue, stream_name(cmd.id))
    end

    def stream_name(id) = "Issue$#{id}"
  end
end
