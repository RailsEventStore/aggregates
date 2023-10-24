require "minitest/autorun"
require "minitest/mock"
require "mutant/minitest/coverage"
require "arkency/command_bus"
require "ruby_event_store"

module ProjectManagement
  module TestPlumbing
    attr_reader :event_store, :command_bus

    def setup
      @command_bus = Arkency::CommandBus.new
      @event_store = RubyEventStore::Client.new
    end
  end
end
