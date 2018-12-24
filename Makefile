test_aggregate_root:
	@bundle exec ruby -Itest -Iaggregate_root -rproject_management test/issue_test.rb

mutate_aggregate_root:
	@bundle exec mutant --include test \
		--include aggregate_root \
		--require project_management \
		--use minitest "ProjectManagement*"

test_query_based:
	@bundle exec ruby -Itest -Iquery_based -rproject_management test/issue_test.rb

mutate_query_based:
	@bundle exec mutant --include test \
		--include query_based \
		--require project_management \
		--use minitest "ProjectManagement*"

test: test_aggregate_root test_query_based

mutate: mutate_aggregate_root mutate_query_based

.PHONY: test mutate
