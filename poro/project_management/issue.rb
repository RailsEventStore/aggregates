module ProjectManagement
  class Issue
    InvalidTransition = Class.new(StandardError)

    attr_reader :status

    def initialize(status)
      @status = status
    end

    def create
      raise InvalidTransition unless !open?
    end

    def resolve
      raise InvalidTransition unless open? || reopened? || in_progress?
    end

    def close
      raise InvalidTransition unless open? || in_progress? || reopened? || resolved?
    end

    def reopen
      raise InvalidTransition unless closed? || resolved?
    end

    def start
      raise InvalidTransition unless open? || reopened?
    end

    def stop
      raise InvalidTransition unless in_progress?
    end

    private
    attr_reader :status

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
