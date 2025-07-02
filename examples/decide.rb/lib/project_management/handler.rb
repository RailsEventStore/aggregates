# frozen_string_literal: true

module ProjectManagement
  class Handler
    def initialize(event_store)
      @decider = Issue::Decider.dimap_on_event(
        fl: ->(event) { infra_to_domain(event) },
        fr: ->(event) { domain_to_infra(event) }
      )
      @repository = Repository.new(event_store)
    end

    def call(cmd)
      state = @repository.load(cmd.id, @decider)
      events = @decider.decide(cmd, state)
      @repository.store(cmd.id, events)
    end

    private

    def infra_to_domain(event)
      case event
      in IssueOpened
        Issue::IssueOpened.new(issue_id: event.data[:issue_id])
      in IssueResolved
        Issue::IssueResolved.new(issue_id: event.data[:issue_id])
      in IssueClosed
        Issue::IssueClosed.new(issue_id: event.data[:issue_id])
      in IssueReopened
        Issue::IssueReopened.new(issue_id: event.data[:issue_id])
      in IssueProgressStarted
        Issue::IssueProgressStarted.new(issue_id: event.data[:issue_id])
      in IssueProgressStopped
        Issue::IssueProgressStopped.new(issue_id: event.data[:issue_id])
      end
    end

    def domain_to_infra(event)
      case event
      in Issue::IssueOpened
        IssueOpened.new(data: { issue_id: event.issue_id })
      in Issue::IssueResolved
        IssueResolved.new(data: { issue_id: event.issue_id })
      in Issue::IssueClosed
        IssueClosed.new(data: { issue_id: event.issue_id })
      in Issue::IssueReopened
        IssueReopened.new(data: { issue_id: event.issue_id })
      in Issue::IssueProgressStarted
        IssueProgressStarted.new(data: { issue_id: event.issue_id })
      in Issue::IssueProgressStopped
        IssueProgressStopped.new(data: { issue_id: event.issue_id })
      in Issue::InvalidTransition
        raise Error
      end
    end
  end
end
