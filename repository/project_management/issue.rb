module ProjectManagement
  class Issue
    InvalidTransition = Class.new(StandardError)

    attr_reader :id
    attr_reader :events

    def initialize(id)
      @id = id
      @events = []
    end

    def clear_events
      @events = []
    end

    def create
      invalid_transition unless can_create?

      @status = :open

      register_event(IssueOpened.new(data: { issue_id: @id }))
    end

    def resolve
      invalid_transition unless can_resolve?

      @status = :resolved

      register_event(IssueResolved.new(data: { issue_id: @id }))
    end

    def close
      invalid_transition unless can_close?

      @status = :closed

      register_event(IssueClosed.new(data: { issue_id: @id }))
    end

    def reopen
      invalid_transition unless can_reopen?

      @status = :reopened

      register_event(IssueReopened.new(data: { issue_id: @id }))
    end

    def start
      invalid_transition unless can_start?

      @status = :in_progress

      register_event(IssueProgressStarted.new(data: { issue_id: @id }))
    end

    def stop
      invalid_transition unless can_stop?

      @status = :open

      register_event(IssueProgressStopped.new(data: { issue_id: @id }))
    end

    private

    def register_event(event)
      @events << event
    end

    def invalid_transition
      raise InvalidTransition
    end

    def open?
      @status.equal? :open
    end

    def closed?
      @status.equal? :closed
    end

    def in_progress?
      @status.equal? :in_progress
    end

    def reopened?
      @status.equal? :reopened
    end

    def resolved?
      @status.equal? :resolved
    end

    def can_reopen?
      closed? || resolved?
    end

    def can_start?
      open? || reopened?
    end

    def can_stop?
      in_progress?
    end

    def can_close?
      open? || in_progress? || reopened? || resolved?
    end

    def can_resolve?
      open? || reopened? || in_progress?
    end

    def can_create?
      !open?
    end
  end
end
