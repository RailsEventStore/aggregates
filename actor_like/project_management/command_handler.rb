module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @repo = AggregateRepository.new(event_store)
    end

    def create(cmd)
      with_issue(cmd.id) do |issue|
        issue.create(cmd.id)
      end
    end

    def resolve(cmd)
      with_issue(cmd.id) do |issue|
        issue.resolve
      end
    end

    def close(cmd)
      with_issue(cmd.id) do |issue|
        issue.close
      end
    end

    def reopen(cmd)
      with_issue(cmd.id) do |issue|
        issue.reopen
      end
    end

    def start(cmd)
      with_issue(cmd.id) do |issue|
        issue.start
      end
    end

    def stop(cmd)
      with_issue(cmd.id) do |issue|
        issue.stop
      end
    end

    private
    attr_reader :repo

    def with_issue(id)
      stream = "Issue$#{id}"
      repo.with_state(IssueState.new, stream) do |state, store|
        yield Issue.new(state).link(store)
      end
    end
  end
end
