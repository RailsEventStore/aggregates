# frozen_string_literal: true

module ProjectManagement
  class Handler
    def initialize(event_store)
      @repository = AggregateRepository.new(event_store)
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

    def create(id)
      with_issue(id) { |issue, store| issue.create(id) { |ev| store.call(ev) } }
    end

    def resolve(id)
      with_issue(id) { |issue, store| issue.resolve { |ev| store.call(ev) } }
    end

    def close(id)
      with_issue(id) { |issue, store| issue.close { |ev| store.call(ev) } }
    end

    def reopen(id)
      with_issue(id) { |issue, store| issue.reopen { |ev| store.call(ev) } }
    end

    def start(id)
      with_issue(id) { |issue, store| issue.start { |ev| store.call(ev) } }
    end

    def stop(id)
      with_issue(id) { |issue, store| issue.stop { |ev| store.call(ev) } }
    end

    private

    def stream_name(id) = "Issue$#{id}"

    def with_issue(id)
      @repository.with_aggregate(Issue.new, stream_name(id)) do |issue, store|
        yield issue, store
      end
    end
  end
end
