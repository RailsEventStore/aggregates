module ProjectManagement
  class IssueProjection
    State = Struct.new(:issue, :version)

    def initialize(event_store)
      @event_store = event_store
    end

    def call(issue, stream_name)
      RubyEventStore::Projection
        .from_stream(stream_name)
        .init(->{ State.new(issue, -1) })
        .when(IssueOpened, method(:apply_opened))
        .when(IssueReopened, method(:apply_reopened))
        .when(IssueClosed, method(:apply_closed))
        .when(IssueResolved, method(:apply_resolved))
        .when(IssueProgressStarted, method(:apply_progress_started))
        .when(IssueProgressStopped, method(:apply_progress_stopped))
        .run(event_store)
    end

    private

    def apply_opened(state, event)
      state.issue.create
      state.version += 1
    end

    def apply_reopened(state, event)
      state.issue.reopen
      state.version += 1
    end

    def apply_closed(state, event)
      state.issue.close
      state.version += 1
    end

    def apply_resolved(state, event)
      state.issue.resolve
      state.version += 1
    end

    def apply_progress_started(state, event)
      state.issue.start
      state.version += 1
    end

    def apply_progress_stopped(state, event)
      state.issue.stop
      state.version += 1
    end

    attr_reader :event_store
  end
end