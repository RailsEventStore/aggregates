require "minitest/autorun"
require "minitest/mock"
require "mutant/minitest/coverage"
require "arkency/command_bus"
require "ruby_event_store"

require_relative "../lib/project_management"
require_relative "../../../shared/test/shared_tests"

module ProjectManagement
  class IssueTest < Minitest::Test
    include SharedTests

    cover "ProjectManagement::Issue*"

    attr_reader :event_store, :command_bus

    def setup
      @command_bus = Arkency::CommandBus.new
      @event_store = RubyEventStore::Client.new
      Configuration.new.(@event_store, @command_bus)
    end
  end
end
