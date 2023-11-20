module ProjectManagement
  class CommandHandler
    def initialize(event_store) = @event_store = event_store

    def create(cmd) = with_state(cmd.id) { |state| Issue.create(state) }
    def resolve(cmd) = with_state(cmd.id) { |state| Issue.resolve(state) }
    def close(cmd) = with_state(cmd.id) { |state| Issue.close(state) }
    def reopen(cmd) = with_state(cmd.id) { |state| Issue.reopen(state) }
    def start(cmd) = with_state(cmd.id) { |state| Issue.start(state) }
    def stop(cmd) = with_state(cmd.id) { |state| Issue.stop(state) }

    private

    def stream_name(id) = "Issue$#{id}"

    def with_state(id)
      state, version =
        @event_store
          .read
          .stream(stream_name(id))
          .reduce([IssueState.new(id), -1]) do |(state, version), event|
            [state.apply(event), version + 1]
        end

      case result = yield(state)
      when Issue::InvalidTransition
        raise Error
      else
        @event_store.publish(
          result,
          stream_name: stream_name(id),
          expected_version: version
        )
      end
    end
  end
end
