require 'pry'
module ProjectManagement
  class Repository
    def initialize(event_store)
      @store = event_store
    end

    def load(id)
      issue = Issue.new(id)

      store.read.stream(stream_name(id)).each do |event|
        build_state(issue, event)
      end

      version = issue.events.size - 1

      issue.clear_events

      [issue, version]
    end

    def save(issue, current_version)
      issue.events.each.with_index do |event, index|
        store.publish(event, stream_name: stream_name(issue.id), expected_version: current_version + index)
      end
      issue.clear_events
    end

    private

    attr_reader :store

    def build_state(issue, event)
      case event
      when IssueOpened
        issue.create
      when IssueResolved
        issue.resolve
      when IssueClosed
        issue.close
      when IssueReopened
        issue.reopen
      when IssueProgressStarted
        issue.start
      when IssueProgressStopped
        issue.stop
      else
        raise 'event not implemented'
      end
    end

    def stream_name(id)
      "Issue$#{id}"
    end
  end
end
