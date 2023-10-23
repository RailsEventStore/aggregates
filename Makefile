EXAMPLES = actor_like \
		   aggregate_root \
           duck_typing \
           extracted_state \
           functional \
           polymorphic \
           poro \
           query_based \
           rails_way \
           repository \
           roles \
           yield_based

$(addprefix test_, $(EXAMPLES)):
	@bundle exec ruby \
		-I$(subst test_,,$@)/lib \
		-rproject_management \
		test/issue_test.rb

$(addprefix mutate_, $(EXAMPLES)):
	@bundle exec mutant run \
		--include $(subst mutate_,,$@)/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

mutate_extracted_state:
	@bundle exec mutant run --include test \
		--include extracted_state/lib \
		--require project_management \
		--ignore-subject "ProjectManagement::Issue#apply_on_state" \
		--ignore-subject "ProjectManagement::Issue#apply" \
		--use minitest "ProjectManagement*"

show_ui:
	@bundle exec ruby ui/duck_typing_ui.rb

test: $(addprefix test_, $(EXAMPLES))

mutate:  $(addprefix mutate_, $(EXAMPLES))

.PHONY: show_ui test mutate
