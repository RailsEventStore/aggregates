require "minitest/autorun"
require "minitest/mock"
require "mutant/minitest/coverage"
require "ruby_event_store"

require_relative "../lib/project_management"

module ProjectManagement
  class IssueTest < Minitest::Test
    include Test.with(
              command_handler: ->(event_store) do
                CommandHandler.new(event_store)
              end,
              event_store: -> { RubyEventStore::Client.new }
            )

    cover "ProjectManagement::Issue*"

    def setup
      ActiveRecord::Base.establish_connection(
        adapter: "sqlite3",
        database: ":memory:"
      )

      ActiveRecord::Schema.verbose = false
      ActiveRecord::Schema.define do
        create_table :issues, force: true do |t|
          t.string :uuid
          t.string :state
        end

        add_index :issues, :uuid, unique: true
      end
    end
  end
end
