# frozen_string_literal: true
module ProjectManagement
  class Issue
    InvalidTransition = Class.new(StandardError)

    def open
      Open.new
    end
    def start
      raise InvalidTransition
    end
    def resolve
      raise InvalidTransition
    end
    def stop
      raise InvalidTransition
    end
    def reopen
      raise InvalidTransition
    end
    def close
      raise InvalidTransition
    end
  end
  class Open
    def open
      raise Issue::InvalidTransition
    end
    def start
      InProgress.new
    end
    def resolve
      Resolved.new
    end
    def stop
      raise Issue::InvalidTransition
    end
    def reopen
      raise Issue::InvalidTransition
    end
    def close
      Closed.new
    end
  end
  class InProgress
    def open
      raise Issue::InvalidTransition
    end
    def start
      raise Issue::InvalidTransition
    end
    def resolve
      Resolved.new
    end
    def stop
      Open.new
    end
    def reopen
      raise Issue::InvalidTransition
    end
    def close
      Closed.new
    end
  end
  class Resolved
    def open
      raise Issue::InvalidTransition
    end
    def start
      raise Issue::InvalidTransition
    end
    def resolve
      raise Issue::InvalidTransition
    end
    def stop
      raise Issue::InvalidTransition
    end
    def reopen
      Open.new
    end
    def close
      Closed.new
    end
  end
  class Closed
    def open
      raise Issue::InvalidTransition
    end
    def start
      raise Issue::InvalidTransition
    end
    def resolve
      raise Issue::InvalidTransition
    end
    def stop
      raise Issue::InvalidTransition
    end
    def reopen
      Open.new
    end
    def close
      raise Issue::InvalidTransition
    end
  end
end
