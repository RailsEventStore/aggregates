module ProjectManagement
  class Handler
    def initialize(event_store) = @event_store = event_store

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
    end

    def create(cmd) = with_state(cmd.id) { |state| Issue.open(state) }
    def resolve(cmd) = with_state(cmd.id) { |state| Issue.resolve(state) }
    def close(cmd) = with_state(cmd.id) { |state| Issue.close(state) }
    def reopen(cmd) = with_state(cmd.id) { |state| Issue.reopen(state) }
    def start(cmd) = with_state(cmd.id) { |state| Issue.start(state) }
    def stop(cmd) = with_state(cmd.id) { |state| Issue.stop(state) }

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
        @event_store.publish(result, stream_name: stream_name(id))
      end
    end
  end
end
