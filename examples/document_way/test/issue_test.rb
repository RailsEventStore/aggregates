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

    def test_save_targets_record_of_expected_id
      assert_query(
        /UPDATE "issues" SET "status" = \? WHERE "issues"."uuid" = \?/
      ) { create_issue }
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

    def assert_query(regex, &block)
      queries = []
      callback = ->(_, _, _, _, payload) { queries << payload[:sql] }

      ActiveSupport::Notifications.subscribed(
        callback,
        "sql.active_record",
        &block
      )
      assert queries.any? { |q| regex.match(q) }, <<~MSG
        Expected query matching #{regex.inspect} to be executed

        Recored queries:
        #{queries.grep_v(/transaction/).join("\n")}
      MSG
    end
  end
end
