require './duck_typing/project_management'
require 'tty-prompt'

class TtyUI
  def initialize
    @issue  = ProjectManagement::Issue.new
    @prompt = TTY::Prompt.new
  end

  def show
    while true do
      @issue = @issue.send(ask_which_method)
    end
  end

  private

  def ask_which_method
    @prompt.select(message, @issue.public_methods(false))
  end

  def message
    "What to do? State: #{@issue.class.name.split('::').last}."
  end
end

TtyUI.new.show




