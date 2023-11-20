module ProjectManagement
  class CommandHandler
    def initialize(event_store) = @event_store = event_store

    def create(cmd) = with_aggregate(cmd.id) { |issue| issue.open }
    def resolve(cmd) = with_aggregate(cmd.id) { |issue| issue.resolve }
    def close(cmd) = with_aggregate(cmd.id) { |issue| issue.close }
    def reopen(cmd) = with_aggregate(cmd.id) { |issue| issue.reopen }
    def start(cmd) = with_aggregate(cmd.id) { |issue| issue.start }
    def stop(cmd) = with_aggregate(cmd.id) { |issue| issue.stop }

    private

    def stream_name(id) = "Issue$#{id}"

    def with_aggregate(id)
      state, version =
        @event_store
          .read
          .stream(stream_name(id))
          .reduce([IssueState.initial(id), -1]) do |(state, version), event|
          [state.apply(event), version + 1]
        end

      yield issue = Issue.new(state)

      @event_store.publish(
        issue.changes,
        stream_name: stream_name(id),
        expected_version: version
      )
    rescue Issue::InvalidTransition
      raise Error
    end
  end
end
