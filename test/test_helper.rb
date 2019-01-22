require 'minitest/autorun'
require 'minitest/mock'
require 'mutant/minitest/coverage'
require 'arkency/command_bus'
require_relative '../lib/project_management'


module ProjectManagement
  module TestPlumbing
    attr_reader :event_store, :command_bus

    def setup
      @command_bus = Arkency::CommandBus.new
      @event_store = RubyEventStore::Client.new(repository: RubyEventStore::InMemoryRepository.new)
    end

    def arrange(*commands)
      commands.each { |command| act(command) }
    end

    def act(command)
      command_bus.(command)
    end

    def assert_events(stream_name, *expected_events)
      scope  = event_store.read.stream(stream_name)
      before = scope.to_a
      yield
      actual_events = before.empty? ? scope.to_a : scope.from(before.last.event_id).to_a
      to_compare = ->(ev) { ev.to_h.slice(:type, :data) }
      assert_equal expected_events.map(&to_compare), actual_events.map(&to_compare)
    end
  end
end