mutate: test
	bundle exec mutant --include lib --include test --require project_management --use minitest "ProjectManagement*"

test:
	bundle exec ruby -Ilib -Itest test/issue_test.rb

.PHONY: test
