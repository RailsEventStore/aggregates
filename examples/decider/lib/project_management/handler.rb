# frozen_string_literal: true
module ProjectManagement
  class Handler
    def initialize(event_store)
      @decider = Issue
      @repository = Repository.new(event_store)
    end

    def call(cmd)
      state = @repository.load(cmd.id, @decider)

      case @decider.decide(cmd, state)
      in [StandardError]
        raise Error
      in [Event => event]
        @repository.store(cmd.id, event)
      end
    end
  end
end
