module ProjectManagement
  class Handler
    def initialize(event_store)
      @repository = AggregateRepository.new(event_store)
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
      with_issue(cmd.id) do |issue, store|
        issue.create(cmd.id) { |ev| store.(ev) }
      end
    end

    def resolve(cmd)
      with_issue(cmd.id) { |issue, store| issue.resolve { |ev| store.(ev) } }
    end

    def close(cmd)
      with_issue(cmd.id) { |issue, store| issue.close { |ev| store.(ev) } }
    end

    def reopen(cmd)
      with_issue(cmd.id) { |issue, store| issue.reopen { |ev| store.(ev) } }
    end

    def start(cmd)
      with_issue(cmd.id) { |issue, store| issue.start { |ev| store.(ev) } }
    end

    def stop(cmd)
      with_issue(cmd.id) { |issue, store| issue.stop { |ev| store.(ev) } }
    end

    private

    attr_reader :repository

    def with_issue(id)
      stream = "Issue$#{id}"
      repository.with_aggregate(Issue.new, stream) do |issue, store|
        yield issue, store
      end
    end
  end
end
