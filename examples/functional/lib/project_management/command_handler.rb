module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
    end

    def create(cmd) = with_state(cmd.id) { |state| Issue.create(state) }
    def resolve(cmd) = with_state(cmd.id) { |state| Issue.resolve(state) }
    def close(cmd) = with_state(cmd.id) { |state| Issue.close(state) }
    def reopen(cmd) = with_state(cmd.id) { |state| Issue.reopen(state) }
    def start(cmd) = with_state(cmd.id) { |state| Issue.start(state) }
    def stop(cmd) = with_state(cmd.id) { |state| Issue.stop(state) }

    private

    def with_state(id)
      stream_name = "Issue$#{id}"
      version = -1
      state = IssueState.new(id)

      @event_store
        .read
        .stream(stream_name)
        .each do |event|
          state.apply(event)
          version += 1
        end
      events = yield state
      @event_store.publish(events, stream_name: stream_name, expected_version: version)
    rescue Issue::InvalidTransition
      raise Error
    end
  end
end
