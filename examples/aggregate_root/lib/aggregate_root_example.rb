require "aggregate_root"

require_relative "../../../shared/lib/project_management"
require_relative "aggregate_root_example/command_handler"
require_relative "aggregate_root_example/issue"

module AggregateRootExample
  class Configuration
    def call(event_store, command_bus)
      handler = CommandHandler.new(event_store)
      command_bus.register(PM::CreateIssue, handler.public_method(:create))
      command_bus.register(PM::ReopenIssue, handler.public_method(:reopen))
      command_bus.register(PM::ResolveIssue, handler.public_method(:resolve))
      command_bus.register(PM::CloseIssue, handler.public_method(:close))
      command_bus.register(PM::StartIssueProgress, handler.public_method(:start))
      command_bus.register(PM::StopIssueProgress, handler.public_method(:stop))
    end
  end
end
