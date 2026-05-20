# By ModuleArchitecture

## Structure

```txt
ByModule
│
├── Security
│ │
│ ├── Entity
│ │ ├── attributes
│ │ ├── constructor
│ │ ├── Getter
│ │ ├── Setter
│ │ └── overrides (toString, equals)
│ │
│ ├── IRepository
│ │ ├── save()
│ │ ├── update()
│ │ ├── delete()
│ │ ├── findById()
│ │ └── findAll()
│ │
│ ├── IService
│ │ ├── create()
│ │ ├── update()
│ │ ├── delete()
│ │ ├── getById()
│ │ └── getAll()
│ │
│ ├── Service
│ │ ├── implement IRepository
│ │ ├── business logic
│ │ ├── validations
│ │ └── DTO mapper ↔ Entity
│ │
│ ├── Controller
│ │ ├── endpoints
│ │ ├── request mapping
│ │ ├── response entity
│ │ ├── validations
│ │ ├── authentication
│ │ ├── authorization
│ │ └── swagger documentation
│ │
│ ├── DISCOUNT
│ │ ├── attributes
│ │ ├── constructor
│ │ ├── Getter
│ │ ├── Setter
│ │ ├── validations
│ │ ├── requestDTO
│ │ └── responseDTO
│ │
│ ├── IDTO
│ │ ├── entityToDTO()
│ │ ├── dtoEntity()
│ │ ├── mapper()
│ │ └── customResponse()
│ │
│ └── Utils
│ └── JWT
│ ├── token generation
│ ├── token validation
│ └── authentication filters
│
├── Inventory
│ │
│ ├── Entity
│ │ ├── attributes
│ │ ├── constructor
│ │ ├── Getter
│ │ ├── Setter
│ │ └── overrides
│ │
│ ├── IRepository
│ │ ├── save()
│ │ ├── update()
│ │ ├── delete()
│ │ ├── findById()
│ │ └── findAll()
│ │
│ ├── IService
│ │ ├── create()
│ │ ├── update()
│ │ ├── delete()
│ │ ├── getById()
│ │ └── getAll()
│ │
│ ├── Service
│ │ ├── implement IRepository
│ │ ├── business logic
│ │ ├── validations
│ │ └── DTO mapper ↔ Entity
│ │
│ ├── Controller
│ │ ├── endpoints
│ │ ├── request mapping
│ │ ├── response entity
│ │ └── swagger documentation
│ │
│ ├── DTO
│ │ ├── requestDTO
│ │ └── responseDTO
│ │
│ ├── IDTO
│ │ ├── entityToDTO()
│ │ └── dtoEntity()
│ │
│ └── Utils
│ └── Process Inventory
│ ├── stock calculations
│ ├── quantity validation
│ └── inventory rules
│
├── Schedule
│ │
│ ├── Entity
│ ├── IRepository
│ ├── IService
│ ├── Service
│ │ ├── business logic
│ │ ├── validations
│ │ └── DTO mapper ↔ Entity
│ │
│ ├── Controller
│ │ ├── endpoints
│ │ ├── authentication
│ │ └── authorization
│ │
│ ├── DTO
│ │ ├── requestDTO
│ │ └── responseDTO
│ │
│ ├── IDTO
│ │ ├── entityToDTO()
│ │ └── dtoEntity()
│ │
│ └── Utils
│ └── ConflictValidator
│ ├── schedule validations
│ ├── conflict detection
│ └── availability rules
│
└── Observation 
│ 
├── Entity 
│ ├── attributes 
│ ├── builder 
│ ├── Getter 
│ ├── Setter 
│ └── overrides 
│ 
├── IRepository 
│ ├── save() 
│ ├── update() 
│ ├── delete() 
│ ├── findById() 
│ └── findAll() 
│ 
├── IService 
│ ├── create() 
│ ├── update() 
│ ├── delete() 
│ ├── getById() 
│ └── getAll() 
│ 
├── Service 
│ ├── implement IRepository 
│ ├── business logic 
│ ├── validations 
│ └── DTO mapper ↔ Entity 
│ 
├── Controller 
│ ├── endpoints 
│ ├── request mapping 
│ └── response entity 
│ 
├── DISCOUNT 
│ ├── requestDTO 
│ └── responseDTO 
│ 
└── IDTO 
├── entityToDTO() 
├── dtoEntity() 
└── mapper()
```