test_aggregate_root:
	@bundle exec ruby -Itest -Iaggregate_root/lib -rproject_management test/issue_test.rb

mutate_aggregate_root:
	@bundle exec mutant run \
		--include aggregate_root/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_query_based:
	@bundle exec ruby -Itest -Iquery_based/lib -rproject_management test/issue_test.rb

mutate_query_based:
	@bundle exec mutant run --include test \
		--include query_based/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_extracted_state:
	@bundle exec ruby -Itest -Iextracted_state/lib -rproject_management test/issue_test.rb

mutate_extracted_state:
	@bundle exec mutant run --include test \
		--include extracted_state/lib \
		--require project_management \
		--ignore-subject "ProjectManagement::Issue#apply_on_state" \
		--ignore-subject "ProjectManagement::Issue#apply" \
		--use minitest "ProjectManagement*"

test_functional:
	@bundle exec ruby -Itest -Ifunctional/lib -rproject_management test/issue_test.rb

mutate_functional:
	@bundle exec mutant run --include test \
		--include functional/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_polymorphic:
	@bundle exec ruby -Itest -Ipolymorphic/lib -rproject_management test/issue_test.rb

mutate_polymorphic:
	@bundle exec mutant run --include test \
		--include polymorphic/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_roles:
	@bundle exec ruby -Itest -Iroles/lib -rproject_management test/issue_test.rb

mutate_roles:
	@bundle exec mutant run --include test \
		--include roles/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_duck_typing:
	@bundle exec ruby -Itest -Iduck_typing/lib -rproject_management test/issue_test.rb

mutate_duck_typing:
	@bundle exec mutant run --include test \
		--include duck_typing/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_yield_based:
	@bundle exec ruby -Itest -Iyield_based/lib -rproject_management test/issue_test.rb

mutate_yield_based:
	@bundle exec mutant run --include test \
		--include yield_based/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_actor_like:
	@bundle exec ruby -Itest -Iactor_like/lib -rproject_management test/issue_test.rb

mutate_actor_like:
	@bundle exec mutant run --include test \
		--include actor_like/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_repository:
	@bundle exec ruby -Itest -Irepository/lib -rproject_management test/issue_test.rb

mutate_repository:
	@bundle exec mutant run --include test \
		--include repository/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_poro:
	@bundle exec ruby -Itest -Iporo/lib -rproject_management test/issue_test.rb

mutate_poro:
	@bundle exec mutant run --include test \
		--include poro/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

test_rails_way:
	@bundle exec ruby -Itest -Irails_way/lib -rproject_management test/issue_test.rb

mutate_rails_way:
	@bundle exec mutant run --include test \
		--include rails_way/lib \
		--require project_management \
		--use minitest "ProjectManagement*"

show_ui:
	@bundle exec ruby ui/duck_typing_ui.rb

test: test_aggregate_root test_query_based test_extracted_state test_functional test_polymorphic test_duck_typing test_yield_based test_actor_like test_repository test_poro test_rails_way test_roles

mutate: mutate_aggregate_root mutate_query_based mutate_extracted_state mutate_functional mutate_polymorphic mutate_duck_typing mutate_yield_based mutate_actor_like mutate_repository mutate_poro mutate_rails_way mutate_roles

.PHONY: test mutate
