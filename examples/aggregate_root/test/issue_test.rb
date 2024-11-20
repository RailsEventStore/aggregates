# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require "mutant/minitest/coverage"
require "ruby_event_store"

require_relative "../lib/project_management"

module ProjectManagement
  class IssueTest < Minitest::Test
    include Test.with(
      handler: ->(event_store) { Handler.new(event_store) },
      event_store: -> { RubyEventStore::Client.new }
    )

    cover "ProjectManagement::Issue*"
  end
end
