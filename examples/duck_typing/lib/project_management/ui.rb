module ProjectManagement
  class UI
    def initialize
      @issue = Issue.new
      @prompt = TTY::Prompt.new
    end

    def show
      @issue = @issue.send(ask_which_method) while true
    end

    private

    def ask_which_method
      @prompt.select(message, @issue.public_methods(false))
    end

    def message
      "What to do? State: #{@issue.class.name.split("::").last}."
    end
  end
end
