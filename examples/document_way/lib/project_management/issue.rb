module ProjectManagement
  class Issue
    State = Data.define(:id, :status)

    class Repository
      class Record < ActiveRecord::Base
        self.table_name = :issues
      end
      private_constant :Record

      def initialize(id) = @id = id

      def store(state) = Record.where(uuid: @id).update(status: state.status)

      def load
        record = Record.find_or_create_by(uuid: @id)
        State.new(id: record.uuid, status: record.status)
      end
    end

    InvalidTransition = Class.new(StandardError)

    attr_reader :state

    def initialize(state)
      @state = state
    end

    def open
      fail if @state.status
      @state = @state.with(status: "open")
      IssueOpened.new(data: { issue_id: @state.id })
    end

    def resolve
      fail unless %w[open in_progress reopened].include? @state.status
      @state = @state.with(status: "resolved")
      IssueResolved.new(data: { issue_id: @state.id })
    end

    def close
      fail unless %w[open in_progress resolved reopened].include? @state.status
      @state = @state.with(status: "closed")
      IssueClosed.new(data: { issue_id: @state.id })
    end

    def reopen
      fail unless %w[resolved closed].include? @state.status
      @state = @state.with(status: "reopened")
      IssueReopened.new(data: { issue_id: @state.id })
    end

    def start
      fail unless %w[open reopened].include? @state.status
      @state = @state.with(status: "in_progress")
      IssueProgressStarted.new(data: { issue_id: @state.id })
    end

    def stop
      fail unless %w[in_progress].include? @state.status
      @state = @state.with(status: "open")
      IssueProgressStopped.new(data: { issue_id: @state.id })
    end

    def fail = raise InvalidTransition
  end
end
