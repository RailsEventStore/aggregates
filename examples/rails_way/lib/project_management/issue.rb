module ProjectManagement
  class Issue < ActiveRecord::Base
    InvalidTransition = Class.new(StandardError)

    include AASM

    aasm column: :state do
      state :open, initial: true
      state :resolved
      state :closed
      state :in_progress
      state :reopened

      event :resolve do
        transitions from: [:open, :in_progress, :reopened], to: :resolved
      end

      event :close do
        transitions from: [:open, :in_progress, :reopened, :resolved], to: :closed
      end

      event :reopen do
        transitions from: [:closed, :resolved], to: :reopened
      end

      event :start do
        transitions from: [:open, :reopened], to: :in_progress
      end

      event :stop do
        transitions from: :in_progress, to: :open
      end
    end
  end
end
