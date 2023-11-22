require_relative "../../../shared/lib/project_management"
require_relative "project_management/command_handler"
require_relative "project_management/issue"

module ProjectManagement
  class Configuration
    def call(event_store, command_bus)
      handler = CommandHandler.new(event_store)
      command_bus.register(CreateIssue, handler.public_method(:handle))
      command_bus.register(ReopenIssue, handler.public_method(:handle))
      command_bus.register(ResolveIssue, handler.public_method(:handle))
      command_bus.register(CloseIssue, handler.public_method(:handle))
      command_bus.register(StartIssueProgress, handler.public_method(:handle))
      command_bus.register(StopIssueProgress, handler.public_method(:handle))
    end
  end
end
