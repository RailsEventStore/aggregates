module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
      @decider = Issue
    end


    def handle(cmd)
      state, version =
        @event_store
          .read
          .stream(stream_name(cmd.id))
          .reduce(
            [@decider.initial_state(cmd.id), -1]
          ) do |(state, version), event|
            [@decider.evolve(state, event), version + 1]
          end

      case result = @decider.decide(cmd, state)
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
