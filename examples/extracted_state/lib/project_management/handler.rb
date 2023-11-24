module ProjectManagement
  class Handler
    def initialize(event_store) = @event_store = event_store

    def call(cmd)
      case cmd
      when CreateIssue
        create(cmd)
      when ResolveIssue
        resolve(cmd)
      when CloseIssue
        close(cmd)
      when ReopenIssue
        reopen(cmd)
      when StartIssueProgress
        start(cmd)
      when StopIssueProgress
        stop(cmd)
      end
    rescue Issue::InvalidTransition
      raise Error
    end

    def create(cmd) = with_aggregate(cmd.id) { |issue| issue.open }
    def resolve(cmd) = with_aggregate(cmd.id) { |issue| issue.resolve }
    def close(cmd) = with_aggregate(cmd.id) { |issue| issue.close }
    def reopen(cmd) = with_aggregate(cmd.id) { |issue| issue.reopen }
    def start(cmd) = with_aggregate(cmd.id) { |issue| issue.start }
    def stop(cmd) = with_aggregate(cmd.id) { |issue| issue.stop }

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