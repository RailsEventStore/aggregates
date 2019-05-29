module ProjectManagement
  class Issue
    def open;    extend(Open)            end
    def start;   raise InvalidTransition end
    def resolve; raise InvalidTransition end
    def stop;    raise InvalidTransition end
    def reopen;  raise InvalidTransition end
    def close;   raise InvalidTransition end
  end
  module Open
    def open;    raise Issue::InvalidTransition end
    def start;   extend(InProgress)             end
    def resolve; extend(Resolved)               end
    def stop;    raise Issue::InvalidTransition end
    def reopen;  raise Issue::InvalidTransition end
    def close;   extend(Closed)                 end
  end
  module InProgress
    def open;    raise Issue::InvalidTransition end
    def start;   raise Issue::InvalidTransition end
    def resolve; extend(Resolved)               end
    def stop;    extend(Open)                   end
    def reopen;  raise Issue::InvalidTransition end
    def close;   extend(Closed)                 end
  end
  module Resolved
    def open;    raise Issue::InvalidTransition end
    def start;   raise Issue::InvalidTransition end
    def resolve; raise Issue::InvalidTransition end
    def stop;    raise Issue::InvalidTransition end
    def reopen;  extend(Open)                   end
    def close;   extend(Closed)                 end
  end
  module Closed
    def open;    raise Issue::InvalidTransition end
    def start;   raise Issue::InvalidTransition end
    def resolve; raise Issue::InvalidTransition end
    def stop;    raise Issue::InvalidTransition end
    def reopen;  extend(Open)                   end
    def close;   raise Issue::InvalidTransition end
  end
end