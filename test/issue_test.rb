require 'test_helper'

class IssueTest < MiniTest::Test
  cover 'Issue*'

  def test_create
    issue = Issue.new(issue_id)
    assert_opened(issue.create)
  end

  def test_close
    issue = Issue.new(issue_id)
    assert_invalid_transition { issue.close }
  end

  def test_resolve
    issue = Issue.new(issue_id)
    assert_invalid_transition { issue.resolve }
  end

  def test_start
    issue = Issue.new(issue_id)
    assert_invalid_transition { issue.start }
  end

  def test_stop
    issue = Issue.new(issue_id)
    assert_invalid_transition { issue.stop }
  end

  def test_reopen
    issue = Issue.new(issue_id)
    assert_invalid_transition { issue.reopen }
  end

  def test_create_from_open
    issue = Issue.new(issue_id)
    issue.create
    assert_invalid_transition { issue.create }
  end

  def test_resolve_from_opened
    issue = Issue.new(issue_id)
    issue.create
    assert_resolved(issue.resolve)
  end

  def test_resolve_from_in_progress
    issue = Issue.new(issue_id)
    issue.create
    issue.start
    assert_resolved(issue.resolve)
  end

  def test_resolve_from_reopened
    issue = Issue.new(issue_id)
    issue.create
    issue.close
    issue.reopen
    assert_resolved(issue.resolve)
  end

  def test_resolve_from_resolved
    issue = Issue.new(issue_id)
    issue.create
    issue.resolve
    assert_invalid_transition { issue.resolve }
  end

  def test_start_from_opened
    issue = Issue.new(issue_id)
    issue.create
    assert_started(issue.start)
  end

  def test_start_from_reopened
    issue = Issue.new(issue_id)
    issue.create
    issue.close
    issue.reopen
    assert_started(issue.start)
  end

  def test_start_from_in_progress
    issue = Issue.new(issue_id)
    issue.create
    issue.start
    assert_invalid_transition { issue.start }
  end

  def test_close_from_opened
    issue = Issue.new(issue_id)
    issue.create
    assert_closed(issue.close)
  end

  def test_close_from_resolved
    issue = Issue.new(issue_id)
    issue.create
    issue.resolve
    assert_closed(issue.close)
  end

  def test_close_from_started
    issue = Issue.new(issue_id)
    issue.create
    issue.start
    assert_closed(issue.close)
  end

  def test_close_from_reopened
    issue = Issue.new(issue_id)
    issue.create
    issue.close
    issue.reopen
    assert_closed(issue.close)
  end

  def test_close_from_closed
    issue = Issue.new(issue_id)
    issue.create
    issue.close
    assert_invalid_transition { issue.close }
  end

  def test_stop_from_started
    issue = Issue.new(issue_id)
    issue.create
    issue.start
    assert_stopped(issue.stop)
  end

  def test_stop_from_open
    issue = Issue.new(issue_id)
    issue.create
    assert_invalid_transition { issue.stop }
  end

  def test_reopen_from_closed
    issue = Issue.new(issue_id)
    issue.create
    issue.close
    assert_reopened(issue.reopen)
  end

  def test_reopen_from_resolved
    issue = Issue.new(issue_id)
    issue.create
    issue.resolve
    assert_reopened(issue.reopen)
  end

  def test_reopen_from_reopened
    issue = Issue.new(issue_id)
    issue.create
    issue.close
    issue.reopen
    assert_invalid_transition { issue.reopen }
  end

  private

  def issue_id
    'c97a6121-f933-4609-9e96-e77dc2f67a16'
  end

  def issue_data
    { issue_id: issue_id }
  end

  def assert_invalid_transition
    assert_raises Issue::InvalidTransition do
      yield
    end
  end

  def assert_opened(applied)
    assert_events [IssueOpened.new(data: issue_data)], applied
  end

  def assert_reopened(applied)
    assert_events [IssueReopened.new(data: issue_data)], applied
  end

  def assert_resolved(applied)
    assert_events [IssueResolved.new(data: issue_data)], applied
  end

  def assert_closed(applied)
    assert_events [IssueClosed.new(data: issue_data)], applied
  end

  def assert_started(applied)
    assert_events [IssueProgressStarted.new(data: issue_data)], applied
  end

  def assert_stopped(applied)
    assert_events [IssueProgressStopped.new(data: issue_data)], applied
  end
end