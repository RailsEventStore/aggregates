module ProjectManagement
  class Handler
    def initialize(event_store) = @event_store = event_store

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
    end

    def create(id) = with_state(id) { |state| Issue.open(state) }
    def resolve(id) = with_state(id) { |state| Issue.resolve(state) }
    def close(id) = with_state(id) { |state| Issue.close(state) }
    def reopen(id) = with_state(id) { |state| Issue.reopen(state) }
    def start(id) = with_state(id) { |state| Issue.start(state) }
    def stop(id) = with_state(id) { |state| Issue.stop(state) }

    private

    def stream_name(id) = "Issue$#{id}"

    def with_state(id)
      state =
        @event_store
          .read
          .stream(stream_name(id))
          .reduce(IssueState.initial(id)) { |state, event| state.apply(event) }

      case result = yield(state)
      when Issue::InvalidTransition
        raise Error
      else
        @event_store.append(result, stream_name: stream_name(id))
      end
    end
  end
end
