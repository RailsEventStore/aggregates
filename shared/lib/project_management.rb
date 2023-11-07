require "ruby_event_store"

module ProjectManagement
  CreateIssue = Data.define(:id)
  ResolveIssue = Data.define(:id)
  CloseIssue = Data.define(:id)
  ReopenIssue = Data.define(:id)
  StartIssueProgress = Data.define(:id)
  StopIssueProgress = Data.define(:id)

  IssueOpened = Class.new(RubyEventStore::Event)
  IssueResolved = Class.new(RubyEventStore::Event)
  IssueClosed = Class.new(RubyEventStore::Event)
  IssueReopened = Class.new(RubyEventStore::Event)
  IssueProgressStarted = Class.new(RubyEventStore::Event)
  IssueProgressStopped = Class.new(RubyEventStore::Event)
end

require_relative "project_management/test"