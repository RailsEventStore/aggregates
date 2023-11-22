module ProjectManagement
  class CommandHandler
    def initialize(event_store) = @event_store = event_store

    def handle(cmd)
      state, version =
        @event_store
          .read
          .stream(stream_name(cmd.id))
          .reduce(
            [Issue.initial_state(cmd.id), -1]
          ) do |(state, version), event|
            [Issue.evolve(state, event), version + 1]
          end

      case result = Issue.decide(cmd, state)
      when StandardError
        raise Error
      else
        @event_store.publish(
          result,
          stream_name: stream_name(cmd.id),
          expected_version: version
        )
      end
    end

    private

    def stream_name(id) = "Issue$#{id}"
  end
end
