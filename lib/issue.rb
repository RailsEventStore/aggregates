require 'aggregate_root'
require 'ruby_event_store'


IssueOpened          = Class.new(RubyEventStore::Event)
IssueResolved        = Class.new(RubyEventStore::Event)
IssueClosed          = Class.new(RubyEventStore::Event)
IssueReopened        = Class.new(RubyEventStore::Event)
IssueProgressStarted = Class.new(RubyEventStore::Event)
IssueProgressStopped = Class.new(RubyEventStore::Event)


class Issue
  include AggregateRoot

  InvalidTransition = Class.new(StandardError)

  def initialize(id)
    @id = id
  end

  def create
    invalid_transition if open?
    apply(IssueOpened.new(data: { issue_id: @id }))
  end

  def resolve
    invalid_transition unless open? || reopened? || in_progress?
    apply(IssueResolved.new(data: { issue_id: @id }))
  end

  def close
    invalid_transition unless open? || in_progress? || reopened? || resolved?
    apply(IssueClosed.new(data: { issue_id: @id }))
  end

  def reopen
    invalid_transition unless closed? || resolved?
    apply(IssueReopened.new(data: { issue_id: @id }))
  end

  def start
    invalid_transition unless open? || reopened?
    apply(IssueProgressStarted.new(data: { issue_id: @id }))
  end

  def stop
    invalid_transition unless in_progress?
    apply(IssueProgressStopped.new(data: { issue_id: @id }))
  end

  private

  def invalid_transition
    raise InvalidTransition
  end

  def open?
    @status.equal? :open
  end

  def closed?
    @status.equal? :closed
  end

  def in_progress?
    @status.equal? :in_progress
  end

  def reopened?
    @status.equal? :reopened
  end

  def resolved?
    @status.equal? :resolved
  end

  on IssueOpened do |ev|
    @status = :open
  end

  on IssueResolved do |ev|
    @status = :resolved
  end

  on IssueClosed do |ev|
    @status = :closed
  end

  on IssueReopened do |ev|
    @status = :reopened
  end

  on IssueProgressStarted do |ev|
    @status = :in_progress
  end

  on IssueProgressStopped do |ev|
    @status = :open
  end
end