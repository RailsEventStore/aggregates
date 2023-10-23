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
	@make -C examples/$(subst test_,,$@) test

$(addprefix mutate_, $(EXAMPLES)):
	@make -C examples/$(subst mutate_,,$@) mutate

$(addprefix install_, $(EXAMPLES)):
	@make -C examples/$(subst install_,,$@) install

show_ui:
	@bundle exec ruby ui/duck_typing_ui.rb

install: $(addprefix install_, $(EXAMPLES))

test: $(addprefix test_, $(EXAMPLES))

mutate:  $(addprefix mutate_, $(EXAMPLES))

.PHONY: show_ui test mutate
