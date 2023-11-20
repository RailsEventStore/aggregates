require "minitest/autorun"
require "minitest/mock"
require "mutant/minitest/coverage"
require "arkency/command_bus"
require "ruby_event_store"

require_relative "../lib/project_management"

module ProjectManagement
  class IssueTest < Minitest::Test
    include Test.with(
              command_bus: -> { Arkency::CommandBus.new },
              event_store: -> { RubyEventStore::Client.new },
              configuration: Configuration.new
            )

    cover "ProjectManagement::Issue*"

    def test_passed_expected_version
      skip "this test sucks"
    end

    def setup
      ActiveRecord::Base.establish_connection(
        adapter: "sqlite3",
        database: ":memory:"
      )

      ActiveRecord::Schema.verbose = false
      ActiveRecord::Schema.define do
        create_table :issues, force: true do |t|
          t.string :uuid
          t.string :status
        end

        add_index :issues, :uuid, unique: true
      end
    end
  end
end
