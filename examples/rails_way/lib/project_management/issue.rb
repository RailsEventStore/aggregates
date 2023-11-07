module ProjectManagement
  class Issue < ActiveRecord::Base
    include AASM

    aasm column: :state do
      state :open, initial: true
      state :resolved
      state :closed
      state :in_progress
      state :reopened

      event :resolve do
        transitions from: %i[open in_progress reopened], to: :resolved
      end

      event :close do
        transitions from: %i[open in_progress reopened resolved], to: :closed
      end

      event :reopen do
        transitions from: %i[closed resolved], to: :reopened
      end

      event :start do
        transitions from: %i[open reopened], to: :in_progress
      end

      event :stop do
        transitions from: :in_progress, to: :open
      end
    end
  end
end
