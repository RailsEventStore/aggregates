module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
    end

    def handle(cmd)
      decider = Issue.new(cmd.id)
      version = -1

      @event_store
        .read
        .stream(stream_name(cmd.id))
        .each
        .with_index do |event, idx|
          decider.evolve(event)
          version = idx
        end

      case result = decider.decide(cmd)
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
