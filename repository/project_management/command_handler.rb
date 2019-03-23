module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @repository = Repository.new(event_store)
    end

    def create(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.create
      end
    end

    def resolve(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.resolve
      end
    end

    def close(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.close
      end
    end

    def reopen(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.reopen
      end
    end

    def start(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.start
      end
    end

    def stop(cmd)
      with_aggregate(cmd.id) do |issue|
        issue.stop
      end
    end

    private

    attr_reader :repository

    def with_aggregate(id)
      issue, version = repository.load(id)
      yield issue
      repository.save(issue, version)
    end
  end
end
