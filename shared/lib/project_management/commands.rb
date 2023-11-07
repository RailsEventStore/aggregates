module ProjectManagement
  class Command < Data.define(:id)
    Rejected = Class.new(StandardError)
  end

  CreateIssue = Class.new(Command)
  ResolveIssue = Class.new(Command)
  CloseIssue = Class.new(Command)
  ReopenIssue = Class.new(Command)
  StartIssueProgress = Class.new(Command)
  StopIssueProgress = Class.new(Command)
end
