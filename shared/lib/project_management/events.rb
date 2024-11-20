# frozen_string_literal: true
module ProjectManagement
  Event =
    Data.define(:event_id, :data, :metadata) do
      def initialize(event_id: SecureRandom.uuid, data: {}, metadata: {}) =
        super(event_id: event_id, data: data, metadata: metadata)
      def event_type = self.class.name
    end

  IssueOpened = Class.new(Event)
  IssueResolved = Class.new(Event)
  IssueClosed = Class.new(Event)
  IssueReopened = Class.new(Event)
  IssueProgressStarted = Class.new(Event)
  IssueProgressStopped = Class.new(Event)
end
