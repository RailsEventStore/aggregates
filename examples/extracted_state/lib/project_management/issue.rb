module ProjectManagement
  class Issue
    InvalidTransition = Class.new(StandardError)

    attr_reader :changes

    def initialize(state)
      @changes = []
      @state = state
    end

    def create
      invalid_transition unless can_create?
      apply(IssueOpened.new(data: { issue_id: state.id }))
    end

    def resolve
      invalid_transition unless can_resolve?
      apply(IssueResolved.new(data: { issue_id: state.id }))
    end

    def close
      invalid_transition unless can_close?
      apply(IssueClosed.new(data: { issue_id: state.id }))
    end

    def reopen
      invalid_transition unless can_reopen?
      apply(IssueReopened.new(data: { issue_id: state.id }))
    end

    def start
      invalid_transition unless can_start?
      apply(IssueProgressStarted.new(data: { issue_id: state.id }))
    end

    def stop
      invalid_transition unless can_stop?
      apply(IssueProgressStopped.new(data: { issue_id: state.id }))
    end

    private

    attr_reader :state

    def invalid_transition
      raise InvalidTransition
    end

    def can_reopen?
      state.closed? || state.resolved?
    end

    def can_start?
      state.open? || state.reopened?
    end

    def can_stop?
      state.in_progress?
    end

    def can_close?
      state.open? || state.in_progress? || state.reopened? || state.resolved?
    end

    def can_resolve?
      state.open? || state.reopened? || state.in_progress?
    end

    def can_create?
      state.initial?
    end

    def apply(event)
      store_changes(event)
      apply_on_state(event)
    end

    def store_changes(event)
      changes << event
    end

    def apply_on_state(event)
      state.apply(event)
    end
  end
end
