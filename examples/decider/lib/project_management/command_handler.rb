module ProjectManagement
  class CommandHandler
    def initialize(event_store) = @event_store = event_store

    def create(cmd) = with_event_store(cmd)
    def resolve(cmd) = with_event_store(cmd)
    def close(cmd) = with_event_store(cmd)
    def reopen(cmd) = with_event_store(cmd)
    def start(cmd) = with_event_store(cmd)
    def stop(cmd) = with_event_store(cmd)

    private

    def stream_name(id) = "Issue$#{id}"

    def with_event_store(cmd)
      state, version =
        @event_store
          .read
          .stream(stream_name(cmd.id))
          .reduce(
            [Issue.initial_state(cmd.id), -1]
          ) do |(state, version), event|
            [Issue.evolve(state, event), version + 1]
          end

      events = Issue.decide(cmd, state)
      raise Error if events.empty?

      @event_store.publish(
        events,
        stream_name: stream_name(cmd.id),
        expected_version: version
      )
    end
  end
end
