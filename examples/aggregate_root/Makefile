install:
	@bundle install

test:
	@bundle exec ruby -Ilib -raggregate_root_example test/issue_test.rb

mutate:
	@bundle exec mutant run

.PHONY: install test mutate
