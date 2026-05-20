#1.Old Project Structure

## Structure

```txt
AllProject
│
├── Entity
│ ├── attributes
│ ├── builder
│ ├── Getter
│ ├── setter
│ └── overrides (toString, equals)
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
│ ├── response entity
│ ├── validations
│ ├── authentication
│ ├── authorization
│ └── swagger documentation
│
├── DISCOUNT
│ ├── attributes
│ ├── builder
│ ├── Getter
│ ├── setter
│ ├── validations
│ ├── requestDTO
│ └── responseDTO
│
├── IDTO
│ ├── entityToDTO()
│ ├── dtoEntity()
│ ├── mapper()
│ └── customResponse()
│
└── Utils 
├── JWT 
├── Encrypt 
└── Validators
```