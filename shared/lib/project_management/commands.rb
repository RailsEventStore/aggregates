module ProjectManagement
  Command = Data.define(:id)

  CreateIssue = Class.new(Command)
  ResolveIssue = Class.new(Command)
  CloseIssue = Class.new(Command)
  ReopenIssue = Class.new(Command)
  StartIssueProgress = Class.new(Command)
  StopIssueProgress = Class.new(Command)

  CommandRejected = Class.new(StandardError)
end
