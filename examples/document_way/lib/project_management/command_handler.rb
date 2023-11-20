module ProjectManagement
  class CommandHandler
    def initialize(event_store)
      @event_store = event_store
    end

    def create(cmd) = with_aggregate(cmd.id) { |issue| issue.open }
    def resolve(cmd) = with_aggregate(cmd.id) { |issue| issue.resolve }
    def close(cmd) = with_aggregate(cmd.id) { |issue| issue.close }
    def reopen(cmd) = with_aggregate(cmd.id) { |issue| issue.reopen }
    def start(cmd) = with_aggregate(cmd.id) { |issue| issue.start }
    def stop(cmd) = with_aggregate(cmd.id) { |issue| issue.stop }

    private

    def stream_name(id) = "Issue$#{id}"

    def with_transaction(&) = ActiveRecord::Base.transaction(&)

    def with_aggregate(id)
      repository = Issue::Repository.new(id)
      issue = Issue.new(repository.load)

      with_transaction do
        @event_store.publish(yield(issue), stream_name: stream_name(id))
        repository.store(issue.state)
      end
    rescue Issue::InvalidTransition
      raise Error
    end
  end
end
