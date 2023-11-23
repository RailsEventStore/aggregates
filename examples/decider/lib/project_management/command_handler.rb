module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
      @decider = Issue
    end

    def call(cmd)
      state =
        @event_store
          .read
          .stream(stream_name(cmd.id))
          .reduce(@decider.initial_state(cmd.id)) do |state, event|
            @decider.evolve(state, event)
          end

      case result = @decider.decide(cmd, state)
      when StandardError
        raise Error
      else
        @event_store.publish(result, stream_name: stream_name(cmd.id))
      end
    end

    private

    def stream_name(id) = "Issue$#{id}"
  end
end
