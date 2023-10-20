module ProjectManagement
  CreateIssue = Data.define(:id)
  ResolveIssue = Data.define(:id)
  CloseIssue = Data.define(:id)
  ReopenIssue = Data.define(:id)
  StartIssueProgress = Data.define(:id)
  StopIssueProgress = Data.define(:id)
end
