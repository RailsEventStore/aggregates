module ProjectManagement
  class Issue
    InvalidTransition = Class.new(StandardError)

    attr_reader :status

    def initialize(status)
      @status = status
    end

    def create
      raise InvalidTransition unless !open?
      @status = :open
    end

    def resolve
      raise InvalidTransition unless open? || reopened? || in_progress?
      @status = :resolved
    end

    def close
      raise InvalidTransition unless open? || in_progress? || reopened? || resolved?
      @status = :closed
    end

    def reopen
      raise InvalidTransition unless closed? || resolved?
      @status = :reopened
    end

    def start
      raise InvalidTransition unless open? || reopened?
      @status = :in_progress
    end

    def stop
      raise InvalidTransition unless in_progress?
      @status = :open
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
