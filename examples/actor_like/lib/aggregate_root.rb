module AggregateRoot
  module ClassMethods
    def on(*event_klasses, &block)
      event_klasses.each do |event_klass|
        name =
          event_klass.name ||
            raise(ArgumentError, "Anonymous class is missing name")
        handler_name = "on_#{name}"
        define_method(handler_name, &block)
        @on_methods ||= {}
        @on_methods[event_klass] = handler_name
        private(handler_name)
      end
    end

    def on_methods
      ancestors
        .select { |k| k.instance_variables.include?(:@on_methods) }
        .map { |k| k.instance_variable_get(:@on_methods) }
        .inject({}, &:merge)
    end
  end

  def self.included(host_class)
    host_class.extend(ClassMethods)
  end

  def initialize(state)
    @state = state
  end

  def link(supervisor)
    @supervisor = supervisor
    self
  end

  def apply(event)
    supervisor.call(event) if supervisor
    state.call(event)
    self
  end

  private

  attr_reader :supervisor, :state
end
