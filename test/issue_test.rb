require "test_helper"

module ProjectManagement
  class IssueTest < Minitest::Test
    include TestPlumbing
    cover "ProjectManagement::Issue*"

    def test_create
      assert_opened { act(create_issue) }
    end

    def test_close
      assert_error { act(close_issue) }
    end

    def test_resolve
      assert_error { act(resolve_issue) }
    end

    def test_start
      assert_error { act(start_issue_progress) }
    end

    def test_stop
      assert_error { act(stop_issue_progress) }
    end

    def test_reopen
      assert_error { act(reopen_issue) }
    end

    def test_start_from_stopped
      arrange(create_issue, start_issue_progress, stop_issue_progress)
      assert_started { act(start_issue_progress) }
    end

    def test_create_from_open
      arrange(create_issue)
      assert_error { act(create_issue) }
    end

    def test_resolve_from_opened
      arrange(create_issue)
      assert_resolved { act(resolve_issue) }
    end

    def test_resolve_from_in_progress
      arrange(create_issue, start_issue_progress)
      assert_resolved { act(resolve_issue) }
    end

    def test_resolve_from_reopened
      arrange(create_issue, close_issue, reopen_issue)
      assert_resolved { act(resolve_issue) }
    end

    def test_resolve_from_resolved
      arrange(create_issue, resolve_issue)
      assert_error { act(resolve_issue) }
    end

    def test_start_from_opened
      arrange(create_issue)
      assert_started { act(start_issue_progress) }
    end

    def test_start_from_reopened
      arrange(create_issue, close_issue, reopen_issue)
      assert_started { act(start_issue_progress) }
    end

    def test_start_from_in_progress
      arrange(create_issue, start_issue_progress)
      assert_error { act(start_issue_progress) }
    end

    def test_close_from_opened
      arrange(create_issue)
      assert_closed { act(close_issue) }
    end

    def test_close_from_resolved
      arrange(create_issue, resolve_issue)
      assert_closed { act(close_issue) }
    end

    def test_close_from_started
      arrange(create_issue, start_issue_progress)
      assert_closed { act(close_issue) }
    end

    def test_close_from_reopened
      arrange(create_issue, close_issue, reopen_issue)
      assert_closed { act(close_issue) }
    end

    def test_close_from_closed
      arrange(create_issue, close_issue)
      assert_error { act(close_issue) }
    end

    def test_stop_from_started
      arrange(create_issue, start_issue_progress)
      assert_stopped { act(stop_issue_progress) }
    end

    def test_stop_from_open
      arrange(create_issue)
      assert_error { act(stop_issue_progress) }
    end

    def test_reopen_from_closed
      arrange(create_issue, close_issue)
      assert_reopened { act(reopen_issue) }
    end

    def test_reopen_from_resolved
      arrange(create_issue, resolve_issue)
      assert_reopened { act(reopen_issue) }
    end

    def test_reopen_from_reopened
      arrange(create_issue, close_issue, reopen_issue)
      assert_error { act(reopen_issue) }
    end

    def test_close_from_create_start_resolved
      arrange(create_issue, start_issue_progress, resolve_issue)
      assert_closed { act(close_issue) }
    end

    def test_start_from_create_start_resolved_reopen
      arrange(create_issue, start_issue_progress, resolve_issue, reopen_issue)
      assert_started { act(start_issue_progress) }
    end

    def test_start_from_create_start_resolved_closed
      arrange(create_issue, start_issue_progress, resolve_issue, close_issue)
      assert_reopened { act(reopen_issue) }
    end

    def test_start_from_create_start_closed
      arrange(create_issue, start_issue_progress, close_issue)
      assert_reopened { act(reopen_issue) }
    end

    def test_close_from_create_start_resolved_closed
      arrange(create_issue, start_issue_progress, resolve_issue, close_issue)
      assert_error { act(close_issue) }
    end

    def test_stream_isolation
      arrange(create_issue, create_additional_issue)
      assert_resolved { act(resolve_issue) }
    end

    def test_passed_expected_version
      assert_version(-1) { act(create_issue) }
      assert_version(0) { act(start_issue_progress) }
      assert_version(1) { act(close_issue) }
      assert_version(2) { act(reopen_issue) }
    end

    private

    def setup
      super
      Configuration.new.(event_store, command_bus)
    end

    def issue_id
      "c97a6121-f933-4609-9e96-e77dc2f67a16"
    end

    def issue_data
      { issue_id: issue_id }
    end

    def stream_name
      "Issue$#{issue_id}"
    end

    def create_issue
      CreateIssue.new(issue_id)
    end

    def create_additional_issue
      CreateIssue.new("96c785c9-5398-4010-b0ad-36bbd1d3f7a1")
    end

    def reopen_issue
      ReopenIssue.new(issue_id)
    end

    def close_issue
      CloseIssue.new(issue_id)
    end

    def resolve_issue
      ResolveIssue.new(issue_id)
    end

    def start_issue_progress
      StartIssueProgress.new(issue_id)
    end

    def stop_issue_progress
      StopIssueProgress.new(issue_id)
    end

    def assert_error
      assert_raises(Issue::InvalidTransition) { yield }
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

    def assert_opened
      assert_events(stream_name, IssueOpened.new(data: issue_data)) { yield }
    end

    def assert_reopened
      assert_events(stream_name, IssueReopened.new(data: issue_data)) { yield }
    end

    def assert_resolved
      assert_events(stream_name, IssueResolved.new(data: issue_data)) { yield }
    end

    def assert_closed
      assert_events(stream_name, IssueClosed.new(data: issue_data)) { yield }
    end

    def assert_started
      assert_events(stream_name, IssueProgressStarted.new(data: issue_data)) do
        yield
      end
    end

    def assert_stopped
      assert_events(stream_name, IssueProgressStopped.new(data: issue_data)) do
        yield
      end
    end
  end
end
