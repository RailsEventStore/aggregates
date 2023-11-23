module ProjectManagement
  module Test
    def self.with(handler:, event_store:)
      Module.new do
        attr_reader :event_store, :handler

        define_method :before_setup do
          @event_store = event_store.call
          @handler = handler.call(@event_store)
        end

        def test_impossible_initial_transitions
          assert_error { start_issue_progress }
          assert_error { stop_issue_progress }
          assert_error { close_issue }
          assert_error { reopen_issue }
          assert_error { resolve_issue }
        end

        def test_open_from_initial
          create_issue

          assert_events(issue_opened)
        end

        def test_open_from_in_progress
          create_issue
          start_issue_progress
          stop_issue_progress

          assert_events(
            issue_opened,
            issue_progress_started,
            issue_progress_stopped
          )
        end

        def test_open_impossible_transitions
          create_issue

          assert_error { create_issue }
          assert_error { stop_issue_progress }
          assert_error { reopen_issue }
        end

        def test_resolved_from_open
          create_issue
          resolve_issue

          assert_events(issue_opened, issue_resolved)
        end

        def test_resolved_from_in_progress
          create_issue
          start_issue_progress
          resolve_issue

          assert_events(issue_opened, issue_progress_started, issue_resolved)
        end

        def test_resolved_from_reopened
          create_issue
          close_issue
          reopen_issue
          resolve_issue

          assert_events(
            issue_opened,
            issue_closed,
            issue_reopened,
            issue_resolved
          )
        end

        def test_resolved_impossible_transitions
          create_issue
          resolve_issue

          assert_error { create_issue }
          assert_error { start_issue_progress }
          assert_error { stop_issue_progress }
          assert_error { resolve_issue }
        end

        def test_closed_from_open
          create_issue
          close_issue

          assert_events(issue_opened, issue_closed)
        end

        def test_closed_from_in_progress
          create_issue
          start_issue_progress
          close_issue

          assert_events(issue_opened, issue_progress_started, issue_closed)
        end

        def test_closed_from_resolved
          create_issue
          resolve_issue
          close_issue

          assert_events(issue_opened, issue_resolved, issue_closed)
        end

        def test_closed_from_reopened
          create_issue
          close_issue
          reopen_issue
          close_issue

          assert_events(
            issue_opened,
            issue_closed,
            issue_reopened,
            issue_closed
          )
        end

        def test_closed_impossible_transitions
          create_issue
          close_issue

          assert_error { create_issue }
          assert_error { start_issue_progress }
          assert_error { stop_issue_progress }
          assert_error { close_issue }
          assert_error { resolve_issue }
        end

        def test_in_progress_from_open
          create_issue
          start_issue_progress

          assert_events(issue_opened, issue_progress_started)
        end

        def test_in_progress_from_reopened
          create_issue
          close_issue
          reopen_issue
          start_issue_progress

          assert_events(
            issue_opened,
            issue_closed,
            issue_reopened,
            issue_progress_started
          )
        end

        def test_in_progress_impossible_transitions
          create_issue
          start_issue_progress

          assert_error { create_issue }
          assert_error { start_issue_progress }
          assert_error { reopen_issue }
        end

        def test_reopened_from_closed
          create_issue
          close_issue
          reopen_issue

          assert_events(issue_opened, issue_closed, issue_reopened)
        end

        def test_reopened_from_resolved
          create_issue
          resolve_issue
          reopen_issue

          assert_events(issue_opened, issue_resolved, issue_reopened)
        end

        def test_reopened_impossible_transitions
          create_issue
          close_issue
          reopen_issue

          assert_error { create_issue }
          assert_error { stop_issue_progress }
          assert_error { reopen_issue }
        end

        def test_in_progress_from_open_after_progress_stopped
          create_issue
          start_issue_progress
          stop_issue_progress
          start_issue_progress

          assert_events(
            issue_opened,
            issue_progress_started,
            issue_progress_stopped,
            issue_progress_started
          )
        end

        def test_in_progress_from_open_after_resolved_and_reopened
          create_issue
          start_issue_progress
          resolve_issue
          reopen_issue
          start_issue_progress

          assert_events(
            issue_opened,
            issue_progress_started,
            issue_resolved,
            issue_reopened,
            issue_progress_started
          )
        end

        def test_reopened_from_closed_after_progress_started
          create_issue
          start_issue_progress
          close_issue
          reopen_issue

          assert_events(
            issue_opened,
            issue_progress_started,
            issue_closed,
            issue_reopened
          )
        end

        def test_reopened_from_closed_after_progress_started_and_resolved
          create_issue
          start_issue_progress
          resolve_issue
          close_issue
          reopen_issue

          assert_events(
            issue_opened,
            issue_progress_started,
            issue_resolved,
            issue_closed,
            issue_reopened
          )
        end

        def test_closed_from_resolved_after_progress_started
          create_issue
          start_issue_progress
          resolve_issue
          close_issue

          assert_events(
            issue_opened,
            issue_progress_started,
            issue_resolved,
            issue_closed
          )
        end

        private

        def issue_id = "c97a6121-f933-4609-9e96-e77dc2f67a16"

        def issue_data = { issue_id: issue_id }

        def stream_name = "Issue$#{issue_id}"

        def create_issue = handler.call(CreateIssue.new(issue_id))

        def reopen_issue = handler.call(ReopenIssue.new(issue_id))

        def close_issue = handler.call(CloseIssue.new(issue_id))

        def resolve_issue = handler.call(ResolveIssue.new(issue_id))

        def start_issue_progress =
          handler.call(StartIssueProgress.new(issue_id))

        def stop_issue_progress = handler.call(StopIssueProgress.new(issue_id))

        def issue_opened = IssueOpened.new(data: issue_data)

        def issue_reopened = IssueReopened.new(data: issue_data)

        def issue_resolved = IssueResolved.new(data: issue_data)

        def issue_closed = IssueClosed.new(data: issue_data)

        def issue_progress_started = IssueProgressStarted.new(data: issue_data)

        def issue_progress_stopped = IssueProgressStopped.new(data: issue_data)

        def assert_error(&) = assert_raises(Error, &)

        def assert_events(*events, comparable: ->(e) { [e.event_type, e.data] })
          assert_equal(
            events.map(&comparable),
            event_store.read.stream(stream_name).map(&comparable)
          )
        end
      end
    end
  end
end
