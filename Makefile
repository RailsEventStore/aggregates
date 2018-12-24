test-aggregate_root:
	@bundle exec ruby -Itest test/aggregate_root_issue_test.rb

mutate-aggregate_root:
	@bundle exec mutant --include test \
		--include aggregate_root \
		--require project_management \
		--use minitest "ProjectManagement*"

test-query_based:
	@bundle exec ruby -Itest test/query_based_issue_test.rb

test: test-aggregate_root test-query_based

mutate: mutate-aggregate_root

.PHONY: test aggregate_root
