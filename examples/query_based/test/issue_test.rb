require "minitest/autorun"
require "minitest/mock"
require "mutant/minitest/coverage"
require "arkency/command_bus"
require "ruby_event_store"

require_relative "../lib/project_management"

module ProjectManagement
  class IssueTest < Minitest::Test
    include SharedTests.with(
              command_bus: -> { Arkency::CommandBus.new },
              event_store: -> { RubyEventStore::Client.new },
              configuration: Configuration.new
            )

    cover "ProjectManagement::Issue*"
  end
end
