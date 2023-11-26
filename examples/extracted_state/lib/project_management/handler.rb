module ProjectManagement
  class Handler
    def initialize(event_store) = @event_store = event_store

    def call(cmd)
      case cmd
      in CreateIssue[id:]
        create(id)
      in ResolveIssue[id:]
        resolve(id)
      in CloseIssue[id:]
        close(id)
      in ReopenIssue[id:]
        reopen(id)
      in StartIssueProgress[id:]
        start(id)
      in StopIssueProgress[id:]
        stop(id)
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
