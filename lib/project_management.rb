require 'ruby_event_store'
require 'aggregate_root'

module ProjectManagement
  IssueOpened          = Class.new(RubyEventStore::Event)
  IssueResolved        = Class.new(RubyEventStore::Event)
  IssueClosed          = Class.new(RubyEventStore::Event)
  IssueReopened        = Class.new(RubyEventStore::Event)
  IssueProgressStarted = Class.new(RubyEventStore::Event)
  IssueProgressStopped = Class.new(RubyEventStore::Event)
end

require 'project_management/issue'