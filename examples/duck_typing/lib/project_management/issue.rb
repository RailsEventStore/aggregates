module ProjectManagement
  class Issue
    def open = Open.new
  end

  class Open
    def start = InProgress.new
    def resolve = Resolved.new
    def close = Closed.new
  end

  class InProgress
    def stop = Open.new
    def close = Closed.new
    def resolve = Resolved.new
  end

  class Resolved
    def close = Closed.new
    def reopen = Open.new
  end

  class Closed
    def reopen = Open.new
  end
end
