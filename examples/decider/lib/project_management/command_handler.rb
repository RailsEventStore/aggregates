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

      @event_store.publish(
        decider.decide(cmd),
        stream_name: stream_name(cmd.id),
        expected_version: version
      )
    rescue Issue::InvalidTransition
      raise Error
    end

    private

    def stream_name(id) = "Issue$#{id}"
  end
end
