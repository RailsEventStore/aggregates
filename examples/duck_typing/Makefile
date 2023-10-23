install:
	@bundle install

test:
	@bundle exec ruby -Ilib -rproject_management test/issue_test.rb

mutate:
	@bundle exec mutant run

.PHONY: install test mutate

ui:
	@bundle exec ruby -Ilib -rproject_management -e "ProjectManagement::UI.new.show"

,PHONY: ui

