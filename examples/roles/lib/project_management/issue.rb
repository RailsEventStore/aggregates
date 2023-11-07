module ProjectManagement
  class Issue
    def open = extend(Open.clone)
    def start = fail
    def resolve = fail
    def stop = fail
    def reopen = fail
    def close = fail

    private
    def fail = raise InvalidTransition
  end

  module Open
    def open = fail
    def start = extend(InProgress.clone)
    def resolve = extend(Resolved.clone)
    def stop = fail
    def reopen = fail
    def close = extend(Closed.clone)
  end

  module InProgress
    def open = fail
    def start = fail
    def resolve = extend(Resolved.clone)
    def stop = extend(Open.clone)
    def reopen = fail
    def close = extend(Closed.clone)
  end

  module Resolved
    def open = fail
    def start = fail
    def resolve = fail
    def stop = fail
    def reopen = extend(Open.clone)
    def close = extend(Closed.clone)
  end

  module Closed
    def open = fail
    def start = fail
    def resolve = fail
    def stop = fail
    def reopen = extend(Open.clone)
    def close = fail
  end
end
