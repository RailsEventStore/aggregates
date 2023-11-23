module ProjectManagement
  class IssueProjection
    State = Struct.new(:status)

    def initialize(event_store)
      @event_store = event_store
    end

    def call(stream_name)
      RubyEventStore::Projection
        .from_stream(stream_name)
        .init(-> { State.new(nil) })
        .when(IssueOpened, method(:apply_opened))
        .when(IssueReopened, method(:apply_reopened))
        .when(IssueClosed, method(:apply_closed))
        .when(IssueResolved, method(:apply_resolved))
        .when(IssueProgressStarted, method(:apply_progress_started))
        .when(IssueProgressStopped, method(:apply_progress_stopped))
        .run(event_store)
    end

    private

    def apply_opened(state, _)
      state.status = :open
    end

    def apply_reopened(state, _)
      state.status = :reopened
    end

    def apply_closed(state, _)
      state.status = :closed
    end

    def apply_resolved(state, _)
      state.status = :resolved
    end

    def apply_progress_started(state, _)
      state.status = :in_progress
    end

    def apply_progress_stopped(state, _)
      state.status = :open
    end

    attr_reader :event_store
  end
end
