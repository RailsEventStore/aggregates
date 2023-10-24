require_relative "test_helper"

module ProjectManagement
  class IssueTest < Minitest::Test
    include TestPlumbing

    cover "ProjectManagement::Issue*"

    def test_create
      assert_opened { create_issue }
    end

    def test_close
      assert_error { close_issue }
    end

    def test_resolve
      assert_error { resolve_issue }
    end

    def test_start
      assert_error { start_issue_progress }
    end

    def test_stop
      assert_error { stop_issue_progress }
    end

    def test_reopen
      assert_error { reopen_issue }
    end

    def test_start_from_stopped
      create_issue
      start_issue_progress
      stop_issue_progress

      assert_started { start_issue_progress }
    end

    def test_create_from_open
      create_issue

      assert_error { create_issue }
    end

    def test_create_from_resolved
      create_issue
      resolve_issue

      assert_error { create_issue }
    end

    def test_create_from_in_progress
      create_issue
      start_issue_progress

      assert_error { create_issue }
    end

    def test_create_from_closed
      create_issue
      close_issue

      assert_error { create_issue }
    end

    def test_reopen_from_in_progress
      create_issue
      start_issue_progress
      assert_error { reopen_issue }
    end

    def test_resolve_from_opened
      create_issue
      assert_resolved { resolve_issue }
    end

    def test_resolve_from_in_progress
      create_issue
      start_issue_progress

      assert_resolved { resolve_issue }
    end

    def test_resolve_from_reopened
      create_issue
      close_issue
      reopen_issue

      assert_resolved { resolve_issue }
    end

    def test_resolve_from_resolved
      create_issue
      resolve_issue

      assert_error { resolve_issue }
    end

    def test_resolve_from_closed
      create_issue
      close_issue

      assert_error { resolve_issue }
    end

    def test_start_from_opened
      create_issue

      assert_started { start_issue_progress }
    end

    def test_start_from_reopened
      create_issue
      close_issue
      reopen_issue
      assert_started { start_issue_progress }
    end

    def test_start_from_in_progress
      create_issue
      start_issue_progress
      assert_error { start_issue_progress }
    end

    def test_start_from_resolved
      create_issue
      resolve_issue

      assert_error { start_issue_progress }
    end

    def test_start_from_closed
      create_issue
      close_issue

      assert_error { start_issue_progress }
    end

    def test_close_from_opened
      create_issue

      assert_closed { close_issue }
    end

    def test_close_from_resolved
      create_issue
      resolve_issue

      assert_closed { close_issue }
    end

    def test_close_from_started
      create_issue
      start_issue_progress

      assert_closed { close_issue }
    end

    def test_close_from_reopened
      create_issue
      close_issue
      reopen_issue

      assert_closed { close_issue }
    end

    def test_close_from_closed
      create_issue
      close_issue

      assert_error { close_issue }
    end

    def test_stop_from_started
      create_issue
      start_issue_progress

      assert_stopped { stop_issue_progress }
    end

    def test_stop_from_open
      create_issue

      assert_error { stop_issue_progress }
    end

    def test_stop_from_resolved
      create_issue
      resolve_issue

      assert_error { stop_issue_progress }
    end

    def test_stop_from_closed
      create_issue
      close_issue

      assert_error { stop_issue_progress }
    end

    def test_reopen_from_closed
      create_issue
      close_issue

      assert_reopened { reopen_issue }
    end

    def test_reopen_from_resolved
      create_issue
      resolve_issue

      assert_reopened { reopen_issue }
    end

    def test_reopen_from_reopened
      create_issue
      close_issue
      reopen_issue

      assert_error { reopen_issue }
    end

    def test_close_from_create_start_resolved
      create_issue
      start_issue_progress
      resolve_issue

      assert_closed { close_issue }
    end

    def test_start_from_create_start_resolved_reopen
      create_issue
      start_issue_progress
      resolve_issue
      reopen_issue

      assert_started { start_issue_progress }
    end

    def test_start_from_create_start_resolved_closed
      create_issue
      start_issue_progress
      resolve_issue
      close_issue

      assert_reopened { reopen_issue }
    end

    def test_start_from_create_start_closed
      create_issue
      start_issue_progress
      close_issue

      assert_reopened { reopen_issue }
    end

    def test_close_from_create_start_resolved_closed
      create_issue
      start_issue_progress
      resolve_issue
      close_issue

      assert_error { close_issue }
    end

    def test_stream_isolation
      create_issue
      create_additional_issue

      assert_resolved { resolve_issue }
    end

    def test_passed_expected_version
      assert_version(-1) { create_issue }
      assert_version(0) { start_issue_progress }
      assert_version(1) { close_issue }
      assert_version(2) { reopen_issue }
    end

    private

    def setup
      super
      Configuration.new.(event_store, command_bus)
    end

    def issue_id = "c97a6121-f933-4609-9e96-e77dc2f67a16"

    def additional_issue_id = "96c785c9-5398-4010-b0ad-36bbd1d3f7a1"

    def issue_data = { issue_id: issue_id }

    def stream_name = "Issue$#{issue_id}"

    def create_issue = act(CreateIssue.new(issue_id))

    def create_additional_issue = act(CreateIssue.new(additional_issue_id))

    def reopen_issue = act(ReopenIssue.new(issue_id))

    def close_issue = act(CloseIssue.new(issue_id))

    def resolve_issue = act(ResolveIssue.new(issue_id))

    def start_issue_progress = act(StartIssueProgress.new(issue_id))

    def stop_issue_progress = act(StopIssueProgress.new(issue_id))

    def assert_error = assert_raises(Issue::InvalidTransition) { yield }

    def assert_opened =
      assert_events(stream_name, IssueOpened.new(data: issue_data)) { yield }

    def assert_reopened =
      assert_events(stream_name, IssueReopened.new(data: issue_data)) { yield }

    def assert_resolved =
      assert_events(stream_name, IssueResolved.new(data: issue_data)) { yield }

    def assert_closed =
      assert_events(stream_name, IssueClosed.new(data: issue_data)) { yield }

    def assert_started =
      assert_events(stream_name, IssueProgressStarted.new(data: issue_data)) do
        yield
      end

    def assert_stopped =
      assert_events(stream_name, IssueProgressStopped.new(data: issue_data)) do
        yield
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
      event_store.publish(
        captured_events,
        stream_name: captured_stream,
        expected_version: captured_version
      )
      assert_equal version_number, captured_version
    end
  end
end
