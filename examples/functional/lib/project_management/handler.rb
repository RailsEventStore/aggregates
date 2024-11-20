# frozen_string_literal: true
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
    end

    def create(id) = with_state(id) { |state| Issue.open(state) }
    def resolve(id) = with_state(id) { |state| Issue.resolve(state) }
    def close(id) = with_state(id) { |state| Issue.close(state) }
    def reopen(id) = with_state(id) { |state| Issue.reopen(state) }
    def start(id) = with_state(id) { |state| Issue.start(state) }
    def stop(id) = with_state(id) { |state| Issue.stop(state) }

    private

    def with_state(id)
      state = @repository.load(id, IssueState.initial(id))

      case yield(state)
      in StandardError
        raise Error
      in Event => event
        @repository.store(id, event)
      end
    end
  end
end
