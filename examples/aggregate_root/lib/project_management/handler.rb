module ProjectManagement
  class Handler
    def initialize(event_store)
      @repository = Repository.new(event_store)
    end

    def call(cmd)
      case cmd
      in CreateIssue[id:]
        create(id)
      in ResolveIssue[id:]
        resolve(id)
      in CloseIssue[id:]
        close(id)
      in ReopenIssue[id:]
        reopen(id)
      in StartIssueProgress[id:]
        start(id)
      in StopIssueProgress[id:]
        stop(id)
      end
    rescue Issue::InvalidTransition
      raise Error
    end

    private

    def create(id)
      issue, stream_name = Issue.new(id), stream_name(id)
      @repository.load(issue, stream_name)
      issue.open
      @repository.store(issue, stream_name)
    end

    def resolve(id)
      issue, stream_name = Issue.new(id), stream_name(id)
      @repository.load(issue, stream_name)
      issue.resolve
      @repository.store(issue, stream_name)
    end

    def close(id)
      issue, stream_name = Issue.new(id), stream_name(id)
      @repository.load(issue, stream_name)
      issue.close
      @repository.store(issue, stream_name)
    end

    def reopen(id)
      issue, stream_name = Issue.new(id), stream_name(id)
      @repository.load(issue, stream_name)
      issue.reopen
      @repository.store(issue, stream_name)
    end

    def start(id)
      issue, stream_name = Issue.new(id), stream_name(id)
      @repository.load(issue, stream_name)
      issue.start
      @repository.store(issue, stream_name)
    end

    def stop(id)
      issue, stream_name = Issue.new(id), stream_name(id)
      @repository.load(issue, stream_name)
      issue.stop
      @repository.store(issue, stream_name)
    end

    def stream_name(id) = "Issue$#{id}"
  end
end
