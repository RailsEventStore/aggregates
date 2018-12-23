require 'test_helper'
require_relative '../aggregate_root/project_management'

module ProjectManagement
  class IssueTest < MiniTest::Test
    include TestPlumbing
    cover 'ProjectManagement::Issue*'

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

    private

    def setup
      super
      Configuration.new.(event_store, command_bus)
    end

    def issue_id
      'c97a6121-f933-4609-9e96-e77dc2f67a16'
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
      assert_raises(Issue::InvalidTransition) do
        yield
      end
    end

    def assert_opened
      assert_events(stream_name, IssueOpened.new(data: issue_data)) do
        yield
      end
    end

    def assert_reopened
      assert_events(stream_name, IssueReopened.new(data: issue_data)) do
        yield
      end
    end

    def assert_resolved
      assert_events(stream_name, IssueResolved.new(data: issue_data)) do
        yield
      end
    end

    def assert_closed
      assert_events(stream_name, IssueClosed.new(data: issue_data)) do
        yield
      end
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
