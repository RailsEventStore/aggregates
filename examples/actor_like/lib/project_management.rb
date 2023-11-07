require_relative "../../../shared/lib/project_management"
require_relative "aggregate_state"
require_relative "aggregate_root"
require_relative "aggregate_repository"
require_relative "project_management/command_handler"
require_relative "project_management/issue_state"
require_relative "project_management/issue"

module ProjectManagement
  class Configuration
    def call(event_store, command_bus)
      handler = CommandHandler.new(event_store)
      command_bus.register(CreateIssue, handler.public_method(:create))
      command_bus.register(ReopenIssue, handler.public_method(:reopen))
      command_bus.register(ResolveIssue, handler.public_method(:resolve))
      command_bus.register(CloseIssue, handler.public_method(:close))
      command_bus.register(StartIssueProgress, handler.public_method(:start))
      command_bus.register(StopIssueProgress, handler.public_method(:stop))
    end
  end
end
