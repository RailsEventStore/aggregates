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

test_extracted_state:
	@bundle exec ruby -Itest -Iextracted_state -rproject_management test/issue_test.rb

mutate_extracted_state:
	@bundle exec mutant --include test \
		--include extracted_state \
		--require project_management \
		--ignore-subject "ProjectManagement::Issue#apply_on_state" \
		--ignore-subject "ProjectManagement::Issue#apply" \
		--use minitest "ProjectManagement*"

test_functional:
	@bundle exec ruby -Itest -Ifunctional_aggregate -rproject_management test/issue_test.rb

mutate_functional:
	@bundle exec mutant --include test \
		--include functional_aggregate \
		--require project_management \
		--use minitest "ProjectManagement*"

test_polymorphic:
	@bundle exec ruby -Itest -Ipolymorphic -rproject_management test/issue_test.rb

mutate_polymorphic:
	@bundle exec mutant --include test \
		--include polymorphic \
		--require project_management \
		--use minitest "ProjectManagement*"

test_polymorphic_variant:
	@bundle exec ruby -Itest -Ipolymorphic_variant -rproject_management test/issue_test.rb

mutate_polymorphic_variant:
	@bundle exec mutant --include test \
		--include polymorphic_variant \
		--require project_management \
		--use minitest "ProjectManagement*"

test_roles:
	@bundle exec ruby -Itest -Iroles -rproject_management test/issue_test.rb

mutate_roles:
	@bundle exec mutant --include test \
		--include roles \
		--require project_management \
		--use minitest "ProjectManagement*"

test_duck_typing:
	@bundle exec ruby -Itest -Iduck_typing -rproject_management test/issue_test.rb

mutate_duck_typing:
	@bundle exec mutant --include test \
		--include duck_typing \
		--require project_management \
		--use minitest "ProjectManagement*"

test_yield_based:
	@bundle exec ruby -Itest -Iyield_based -rproject_management test/issue_test.rb

mutate_yield_based:
	@bundle exec mutant --include test \
		--include yield_based \
		--require project_management \
		--use minitest "ProjectManagement*"

test_actor_like:
	@bundle exec ruby -Itest -Iactor_like -rproject_management test/issue_test.rb

mutate_actor_like:
	@bundle exec mutant --include test \
		--include actor_like\
		--require project_management \
		--use minitest "ProjectManagement*"

test_repository:
	@bundle exec ruby -Itest -Irepository -rproject_management test/issue_test.rb

mutate_repository:
	@bundle exec mutant --include test \
		--include repository\
		--require project_management \
		--use minitest "ProjectManagement*"

show_ui:
	@bundle exec ruby ui/duck_typing_ui.rb

test: test_aggregate_root test_query_based test_extracted_state test_functional test_polymorphic test_duck_typing test_yield_based test_actor_like test_repository_like

mutate: mutate_aggregate_root mutate_query_based mutate_extracted_state mutate_functional mutate_polymorphic mutate_duck_typing mutate_yield_based mutate_actor_like mutate_repository

.PHONY: test mutate
