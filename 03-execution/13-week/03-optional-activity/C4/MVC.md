# MVC (Model-View-Controller)

## Application Structure in the System

```txt
MVC
│
├── Model
│ │
│ ├── Schedule
│ │ ├── Attributes
│ │ ├── Constructor
│ │ ├── Getter
│ │ ├── Setter
│ │ ├── Business Rules
│ │ └── Overrides (toString, equals)
│ │
│ ├── Instructor
│ │ ├── Attributes
│ │ ├── Constructor
│ │ ├── Getter
│ │ ├── Setter
│ │ └── Overrides
│ │
│ └── Environment
│ ├── Attributes
│ ├── Constructor
│ ├── Getter
│ ├── Setter
│ └── Overrides
│
├── View
│ │
│ ├── Dashboard
│ │ ├── Graphical Interface
│ │ ├── Main Menu
│ │ ├── Visual Components
│ │ └── Data Visualization
│ │
│ └── SchedulerUI
│ ├── Forms
│ ├── Tables
│ ├── Buttons
│ ├── Data Capture
│ └── User Messages
│
└── Controller
│
└── ScheduleController
├── Receives Requests
├── Communicates View ↔ Model
├── Processes Events

├── validations
├── flow logic
└── view updates
```