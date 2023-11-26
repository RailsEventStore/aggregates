module ProjectManagement
  class Handler
    def initialize(event_store) = @event_store = event_store

    def call(cmd)
      case cmd
      when CreateIssue
        create(cmd.id)
      when ResolveIssue
        resolve(cmd.id)
      when CloseIssue
        close(cmd.id)
      when ReopenIssue
        reopen(cmd.id)
      when StartIssueProgress
        start(cmd.id)
      when StopIssueProgress
        stop(cmd.id)
      end
    rescue Issue::InvalidTransition
      raise Error
    end

    def create(id) = with_aggregate(id) { |issue| issue.open }
    def resolve(id) = with_aggregate(id) { |issue| issue.resolve }
    def close(id) = with_aggregate(id) { |issue| issue.close }
    def reopen(id) = with_aggregate(id) { |issue| issue.reopen }
    def start(id) = with_aggregate(id) { |issue| issue.start }
    def stop(id) = with_aggregate(id) { |issue| issue.stop }

    private

    def stream_name(id) = "Issue$#{id}"

    def with_aggregate(id)
      state =
        @event_store
          .read
          .stream(stream_name(id))
          .reduce(IssueState.initial(id)) { |state, event| state.apply(event) }

      yield issue = Issue.new(state)

      @event_store.append(issue.changes, stream_name: stream_name(id))
    end
  end
end
