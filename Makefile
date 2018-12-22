mutate: test
	bundle exec mutant --include lib --include test --require issue --use minitest "Issue*"

test:
	bundle exec ruby -Ilib -Itest test/issue_test.rb


.PHONY: test
