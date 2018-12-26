module ProjectManagement
  CreateIssue        = Struct.new(:id)
  ResolveIssue       = Struct.new(:id)
  CloseIssue         = Struct.new(:id)
  ReopenIssue        = Struct.new(:id)
  StartIssueProgress = Struct.new(:id)
  StopIssueProgress  = Struct.new(:id)
end