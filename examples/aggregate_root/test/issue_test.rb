require "minitest/autorun"
require "minitest/mock"
require "mutant/minitest/coverage"
require "arkency/command_bus"
require "ruby_event_store"

require_relative "../lib/aggregate_root_example"

module AggregateRootExample
  class IssueTest < Minitest::Test
    cover "AggregateRootExample::Issue*"

    include ProjectManagement::Test.with(
              command_bus: -> { Arkency::CommandBus.new },
              event_store: -> { RubyEventStore::Client.new },
              configuration: Configuration.new
            )
  end
end
