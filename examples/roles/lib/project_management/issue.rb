module ProjectManagement
  class Issue
    def open = extend(Open.clone)
    def start = raise InvalidTransition
    def resolve = raise InvalidTransition
    def stop = raise InvalidTransition
    def reopen = raise InvalidTransition
    def close = raise InvalidTransition
  end

  module Open
    def open = raise Issue::InvalidTransition
    def start = extend(InProgress.clone)
    def resolve = extend(Resolved.clone)
    def stop = raise Issue::InvalidTransition
    def reopen = raise Issue::InvalidTransition
    def close = extend(Closed.clone)
  end

  module InProgress
    def open = raise Issue::InvalidTransition
    def start = raise Issue::InvalidTransition
    def resolve = extend(Resolved.clone)
    def stop = extend(Open.clone)
    def reopen = raise Issue::InvalidTransition
    def close = extend(Closed.clone)
  end

  module Resolved
    def open = raise Issue::InvalidTransition
    def start = raise Issue::InvalidTransition
    def resolve = raise Issue::InvalidTransition
    def stop = raise Issue::InvalidTransition
    def reopen = extend(Open.clone)
    def close = extend(Closed.clone)
  end

  module Closed
    def open = raise Issue::InvalidTransition
    def start = raise Issue::InvalidTransition
    def resolve = raise Issue::InvalidTransition
    def stop = raise Issue::InvalidTransition
    def reopen = extend(Open.clone)
    def close = raise Issue::InvalidTransition
  end
end
