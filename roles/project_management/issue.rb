module ProjectManagement
  class Issue
    def open;    extend(Open.clone)      end
    def start;   raise InvalidTransition end
    def resolve; raise InvalidTransition end
    def stop;    raise InvalidTransition end
    def reopen;  raise InvalidTransition end
    def close;   raise InvalidTransition end
  end
  module Open
    def open;    raise Issue::InvalidTransition end
    def start;   extend(InProgress.clone)       end
    def resolve; extend(Resolved.clone)         end
    def stop;    raise Issue::InvalidTransition end
    def reopen;  raise Issue::InvalidTransition end
    def close;   extend(Closed.clone)           end
  end
  module InProgress
    def open;    raise Issue::InvalidTransition end
    def start;   raise Issue::InvalidTransition end
    def resolve; extend(Resolved.clone)         end
    def stop;    extend(Open.clone)             end
    def reopen;  raise Issue::InvalidTransition end
    def close;   extend(Closed.clone)           end
  end
  module Resolved
    def open;    raise Issue::InvalidTransition end
    def start;   raise Issue::InvalidTransition end
    def resolve; raise Issue::InvalidTransition end
    def stop;    raise Issue::InvalidTransition end
    def reopen;  extend(Open.clone)             end
    def close;   extend(Closed.clone)           end
  end
  module Closed
    def open;    raise Issue::InvalidTransition end
    def start;   raise Issue::InvalidTransition end
    def resolve; raise Issue::InvalidTransition end
    def stop;    raise Issue::InvalidTransition end
    def reopen;  extend(Open.clone)             end
    def close;   raise Issue::InvalidTransition end
  end
end