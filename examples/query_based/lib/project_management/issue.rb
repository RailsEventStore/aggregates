module ProjectManagement
  class Issue
    def create = @status = :open
    def resolve = @status = :resolved
    def close = @status = :closed
    def reopen = @status = :reopened
    def start = @status = :in_progress
    def stop = @status = :open

    def can_create? = @status.nil?
    def can_reopen? = %i[closed resolved].include? @status
    def can_start? = %i[open reopened].include? @status
    def can_stop? = %i[in_progress].include? @status
    def can_close? = %i[open in_progress reopened resolved].include? @status
    def can_resolve? = %i[open reopened in_progress].include? @status
  end
end
