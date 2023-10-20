module ProjectManagement
  class Issue
    InvalidTransition = Class.new(StandardError)

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def create
      self.status = :open
    end

    def resolve
      self.status = :resolved
    end

    def close
      self.status = :closed
    end

    def reopen
      self.status = :reopened
    end

    def start
      self.status = :in_progress
    end

    def stop
      self.status = :open
    end

    def can_create?
      !open?
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

    private

    attr_accessor :status

    def open?
      status.equal? :open
    end

    def closed?
      status.equal? :closed
    end

    def in_progress?
      status.equal? :in_progress
    end

    def reopened?
      status.equal? :reopened
    end

    def resolved?
      status.equal? :resolved
    end
  end
end
