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
      issue, stream_name = Issue.new(cmd.id), stream_name(cmd.id)
      @repository.load(issue, stream_name)
      issue.open
      @repository.store(issue, stream_name)
    end

    def resolve(cmd)
      issue, stream_name = Issue.new(cmd.id), stream_name(cmd.id)
      @repository.load(issue, stream_name)
      issue.resolve
      @repository.store(issue, stream_name)
    end

    def close(cmd)
      issue, stream_name = Issue.new(cmd.id), stream_name(cmd.id)
      @repository.load(issue, stream_name)
      issue.close
      @repository.store(issue, stream_name)
    end

    def reopen(cmd)
      issue, stream_name = Issue.new(cmd.id), stream_name(cmd.id)
      @repository.load(issue, stream_name)
      issue.reopen
      @repository.store(issue, stream_name)
    end

    def start(cmd)
      issue, stream_name = Issue.new(cmd.id), stream_name(cmd.id)
      @repository.load(issue, stream_name)
      issue.start
      @repository.store(issue, stream_name)
    end

    def stop(cmd)
      issue, stream_name = Issue.new(cmd.id), stream_name(cmd.id)
      @repository.load(issue, stream_name)
      issue.stop
      @repository.store(issue, stream_name)
    end

    def stream_name(id) = "Issue$#{id}"
  end
end
