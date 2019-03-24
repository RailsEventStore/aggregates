# Aggregates

An experiment of different aggregate implementations. All implementations must pass same test suite: arranged with commands, asserted with events.

## Experiment subject

Quite typical workflow of an issue in a popular task tracking software (Jira).

![workflow](https://confluence.atlassian.com/adminjiraserver072/files/828787890/828787899/1/1456788407758/JIRA+Workflow.png)

## Existing experiments

### Classical example

[source](aggregate_root)

- probably most recognized implementation (appeared in [Greg Young's CQRS example](https://github.com/gregoryyoung/m-r/blob/31d315faf272182d7567a038bbe832a73b879737/SimpleCQRS/Domain.cs#L63-L96))
- does not expose its internal state via reader methods
- testability without persistence (just check if operation yields correct event)

Module source: https://github.com/RailsEventStore/rails_event_store/tree/5378b343dbf427f5ea68f7ddfc66d6a449a6ff82/aggregate_root/lib

### Aggregate with exposed queries

[source](query_based)

- clear separation of state sourcing (with projection)
- aggregate not aware of events
- handler queries aggregate whether particular action is possible

### Aggregate with extracted state

[source](extracted_state)

- aggregate initialized with already sourced state

### Functional aggregate

[source](functional_aggregate)

- no single aggregate, just functions that take state and return events

### Polymorphic

[source](polymorphic)

- domain classes per each state
- no messaging in domain classes
- no id in domain class
- invalid state transition cared by raising exception

More: https://blog.arkency.com/make-your-ruby-code-more-modular-and-functional-with-polymorphic-aggregate-classes/

### Duck typing

[source](duck_typing)

- domain classes per each state
- no messaging in domain classes
- no id in domain class
- invalid state transition cared by not having such methods on objects (duck)

### Aggregate with yield

[source](yield_based)

- yield is used to publish events (no unpublished_events in aggregate)
- aggregate repository separated from logic

### Aggregate with repository

[source](repository)

- aggregate is unware of infrastructure
- aggregate can built itself from events (but it could be recreated in any way)
- aggregate keeps the state
- aggregate registers events aka changes
- aggregate provides API to read registered events
- Infrastructure (through repository in this case) is responsible for building/saving the aggregate so it could be done in any way - Event Sourcing, serialization etc
