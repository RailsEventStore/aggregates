aggregate_root:
	@bundle exec ruby -Itest test/aggregate_root_issue_test.rb
	@bundle exec mutant --include test \
		--include aggregate_root \
		--require project_management \
		--use minitest "ProjectManagement*"

test: aggregate_root

.PHONY: test aggregate_root
