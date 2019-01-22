module ProjectManagement
  class Issue
    def open;    Open.new       end
  end
  class Open
    def start;   InProgress.new end
    def resolve; Resolved.new   end
    def close;   Closed.new     end
  end
  class InProgress
    def stop;    Open.new       end
    def close;   Closed.new     end
    def resolve; Resolved.new   end
  end
  class Resolved
    def close;   Closed.new     end
    def reopen;  Open.new       end
  end
  class Closed
    def reopen;  Open.new       end
  end
end