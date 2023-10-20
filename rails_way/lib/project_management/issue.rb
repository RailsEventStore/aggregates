module ProjectManagement
  class Issue < ActiveRecord::Base
    class InvalidTransition < StandardError
    end

    def open
      invalid_transition unless can_create?
      self.state = "open"
    end

    def resolve
      invalid_transition unless can_resolve?
      self.state = "resolved"
    end

    def close
      invalid_transition unless can_close?
      self.state = "closed"
    end

    def reopen
      invalid_transition unless can_reopen?
      self.state = "reopened"
    end

    def start
      invalid_transition unless can_start?
      self.state = "in_progress"
    end

    def stop
      invalid_transition unless can_stop?
      self.state = "open"
    end

    private

    def invalid_transition
      raise InvalidTransition
    end

    def open?
      state == "open"
    end

    def closed?
      state == "closed"
    end

    def in_progress?
      state == "in_progress"
    end

    def reopened?
      state == "reopened"
    end

    def resolved?
      state == "resolved"
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
