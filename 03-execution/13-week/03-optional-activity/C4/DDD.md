# DDD (Domain-Driven Design)

## Structure

```txt
DDD
│
├── Domain
│ │
│ ├── Entity
│ │ ├── Attributes
│ │ ├── Constructor
│ │ ├── Getter
│ │ ├── Setter
│ │ ├── Business Rules
│ │ └── Domain Behavior
│ │
│ ├── ValueObjects
│ │ ├── Immutable Objects
│ │ ├── Validations
│ │ ├── Value comparison
│ │ └── Specific rules
│ │
│ ├── Aggregates
│ │ ├── Aggregate Root
│ │ ├── Entity grouping
│ │ ├── Consistency checking
│ │ └── Domain rules
│ │
│ ├── Repository Interfaces
│ │ ├── save()
│ │ ├── update()
│ │ ├── delete()
│ │ ├── findById()
│ │ └── findAll()
│ │
│ └── DomainServices
│ ├── complex logic
│ ├── business rules
│ ├── coordination between entities
│ └── domain processes
│
├── Application
│ │
│ ├── UseCases
│ │ ├── execute actions
│ │ ├── orchestrate processes
│ │ ├── Application Logic
│ │ └── Domain Coordination
│ │
│ ├── DTOs
│ │ ├── RequestDTO
│ │ ├── ResponseDTO
│ │ ├── Validations
│ │ └── Data Transfer
│ │
│ └── Interfaces
│ ├── Contracts
│ ├── Abstractions
│ └── Inter-Layer Communication
│
├── Infrastructure
│ │
│ ├── Persistence
│ │ ├── Database Configuration
│ │ ├── ORM
│ │ ├── Persistent Entities
│ │ └── Data Connection
│ │
│ ├── Security
│ │ ├── JWT
│ │ ├── Authentication
│ │ ├── Authorization
│ │ └── Security Filters
│ │
│ ├── External Services
│ │ ├── APIs External
│ │ ├── Microservices
│ │ ├── Integrations
│ │ └── Third-Party Services
│ │
│ └── Repositories
│   ├── Implementation Interfaces
│   ├── Data Access
│   ├── Queries
│   └── Persistence
|
└── Presentation
│ |
| ├── Controllers
│ | ├── Endpoints
│ | ├── Request Mapping
│ | ├── Response Entities
│ | ├── Validations
│ | └── API Documentation
│
└── Views
| | ├── User Interface
| | ├── Forms
| | ├── Data Visualization
| | └── User Interaction
```