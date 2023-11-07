module ProjectManagement
  module Test
    def self.with(command_bus:, event_store:, configuration:)
      Module.new do
        attr_reader :event_store, :command_bus

        define_method :before_setup do
          @command_bus = command_bus.call
          @event_store = event_store.call
          configuration.call(@event_store, @command_bus)
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

          assert_events issue_opened
        end

        def test_open_from_in_progress
          create_issue
          start_issue_progress
          stop_issue_progress

          assert_events issue_opened, issue_progress_started, issue_progress_stopped
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

          assert_events issue_opened, issue_resolved
        end

        def test_resolved_from_in_progress
          create_issue
          start_issue_progress
          resolve_issue

          assert_events issue_opened, issue_progress_started, issue_resolved
        end

        def test_resolved_from_reopened
          create_issue
          close_issue
          reopen_issue
          resolve_issue

          assert_events issue_opened, issue_closed, issue_reopened, issue_resolved
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

          assert_events issue_opened, issue_closed
        end

        def test_closed_from_in_progress
          create_issue
          start_issue_progress
          close_issue

          assert_events issue_opened, issue_progress_started, issue_closed
        end

        def test_closed_from_resolved
          create_issue
          resolve_issue
          close_issue

          assert_events issue_opened, issue_resolved, issue_closed
        end

        def test_closed_from_reopened
          create_issue
          close_issue
          reopen_issue
          close_issue

          assert_events issue_opened, issue_closed, issue_reopened, issue_closed
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

          assert_events issue_opened, issue_progress_started
        end

        def test_in_progress_from_reopened
          create_issue
          close_issue
          reopen_issue
          start_issue_progress

          assert_events issue_opened, issue_closed, issue_reopened, issue_progress_started
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

          assert_events issue_opened, issue_closed, issue_reopened
        end

        def test_reopened_from_resolved
          create_issue
          resolve_issue
          reopen_issue

          assert_events issue_opened, issue_resolved, issue_reopened
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

          assert_events issue_opened, issue_progress_started, issue_progress_stopped, issue_progress_started
        end

        def test_in_progress_from_open_after_resolved_and_reopened
          create_issue
          start_issue_progress
          resolve_issue
          reopen_issue
          start_issue_progress

          assert_events issue_opened, issue_progress_started, issue_resolved, issue_reopened, issue_progress_started
        end

        def test_reopened_from_closed_after_progress_started
          create_issue
          start_issue_progress
          close_issue
          reopen_issue

          assert_events issue_opened, issue_progress_started, issue_closed, issue_reopened
        end

        def test_reopened_from_closed_after_progress_started_and_resolved
          create_issue
          start_issue_progress
          resolve_issue
          close_issue
          reopen_issue

          assert_events issue_opened, issue_progress_started, issue_resolved, issue_closed, issue_reopened
        end

        def test_closed_from_resolved_after_progress_started
          create_issue
          start_issue_progress
          resolve_issue
          close_issue

          assert_events issue_opened, issue_progress_started, issue_resolved, issue_closed
        end

        def test_stream_isolation
          create_issue
          create_additional_issue
          resolve_issue

          assert_events issue_opened, issue_resolved
        end

        def test_passed_expected_version
          assert_version(-1) { create_issue }
          assert_version(0) { start_issue_progress }
          assert_version(1) { close_issue }
          assert_version(2) { reopen_issue }
        end

        private

        def issue_id = "c97a6121-f933-4609-9e96-e77dc2f67a16"

        def additional_issue_id = "96c785c9-5398-4010-b0ad-36bbd1d3f7a1"

        def issue_data = { issue_id: issue_id }

        def stream_name = "Issue$#{issue_id}"

        def create_issue = command_bus.(CreateIssue.new(issue_id))

        def create_additional_issue = command_bus.(CreateIssue.new(additional_issue_id))

        def reopen_issue = command_bus.(ReopenIssue.new(issue_id))

        def close_issue = command_bus.(CloseIssue.new(issue_id))

        def resolve_issue = command_bus.(ResolveIssue.new(issue_id))

        def start_issue_progress = command_bus.(StartIssueProgress.new(issue_id))

        def stop_issue_progress = command_bus.(StopIssueProgress.new(issue_id))

        def issue_opened = IssueOpened.new(data: issue_data)

        def issue_reopened = IssueReopened.new(data: issue_data)

        def issue_resolved = IssueResolved.new(data: issue_data)

        def issue_closed = IssueClosed.new(data: issue_data)

        def issue_progress_started = IssueProgressStarted.new(data: issue_data)

        def issue_progress_stopped = IssueProgressStopped.new(data: issue_data)

        def assert_error(&) = assert_raises(Error, &)

        def assert_events(*events, comparable: ->(e) { [e.event_type, e.data] })
          assert_equal events.map(&comparable), event_store.read.stream(stream_name).map(&comparable)
        end

        def assert_version(version_number)
          captured_events = []
          captured_version = nil
          captured_stream = nil
          fake_publish = ->(events, stream_name:, expected_version:) do
            captured_events = events
            captured_stream = stream_name
            captured_version = expected_version
          end
          event_store.stub(:publish, fake_publish) { yield }
          event_store.publish(captured_events, stream_name: captured_stream, expected_version: captured_version)
          assert_equal version_number, captured_version
        end
      end
    end
  end
end
