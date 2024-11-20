# frozen_string_literal: true

module ProjectManagement
  class IssueProjection
    State = Struct.new(:status)

    def initialize(event_store)
      @event_store = event_store
    end

    def call(stream_name)
      RubyEventStore::Projection
        .from_stream(stream_name)
        .init(-> { State.new })
        .when(IssueOpened, ->(state, _) { state.status = :open })
        .when(IssueReopened, ->(state, _) { state.status = :reopened })
        .when(IssueClosed, ->(state, _) { state.status = :closed })
        .when(IssueResolved, ->(state, _) { state.status = :resolved })
        .when(
          IssueProgressStarted,
          ->(state, _) { state.status = :in_progress }
        )
        .when(IssueProgressStopped, ->(state, _) { state.status = :open })
        .run(@event_store)
    end
  end
end
