module ProjectManagement
  class Handler
    def initialize(event_store)
      @decider = Issue
      @repository = Repository.new(event_store)
    end

    def call(cmd)
      state = @repository.load(cmd.id, @decider)

      case result = @decider.decide(cmd, state)
      when StandardError
        raise Error
      else
        @repository.store(cmd.id, result)
      end
    end
  end
end
