# frozen_string_literal: true

module ProjectManagement
  Issue =
    Data.define(:status) do
      def self.initial = new(status: nil)

      def open = with(status: :open)
      def resolve = with(status: :resolved)
      def close = with(status: :closed)
      def reopen = with(status: :reopened)
      def start = with(status: :in_progress)
      def stop = with(status: :open)

      def can_create? = status.nil?
      def can_reopen? = %i[closed resolved].include? status
      def can_start? = %i[open reopened].include? status
      def can_stop? = %i[in_progress].include? status
      def can_close? = %i[open in_progress reopened resolved].include? status
      def can_resolve? = %i[open reopened in_progress].include? status
    end
end
