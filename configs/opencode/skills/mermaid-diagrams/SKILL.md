---
name: mermaid-diagrams
description: Use when creating Mermaid diagrams - covers flowcharts, sequence diagrams, class diagrams, state diagrams, ER diagrams, Gantt charts, and architecture visualization. Triggers: "create diagram", "visualize", "map out", "show the flow", "architecture diagram", "sequence diagram", "flowchart"
---

# Mermaid Diagram Skill

Use Mermaid diagrams as the default visual documentation standard. Diagrams live in markdown, diff cleanly in git, render natively on GitHub/GitLab/Notion.

## Diagram Types

### Flowchart
```mermaid
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E[End]
    D --> E
```

### Sequence Diagram
```mermaid
sequenceDiagram
    participant Client
    participant Server
    participant Database
    
    Client->>Server: Request
    Server->>Database: Query
    Database-->>Server: Result
    Server-->>Client: Response
```

### State Diagram
```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Loading: Fetch
    Loading --> Success: Data received
    Loading --> Error: Failed
    Success --> [*]
    Error --> Idle: Retry
```

### Class Diagram
```mermaid
classDiagram
    class Animal {
        +String name
        +makeSound()
    }
    class Dog {
        +bark()
    }
    class Cat {
        +meow()
    }
    Animal <|-- Dog
    Animal <|-- Cat
```

### ER Diagram
```mermaid
erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ LINE-ITEM : contains
    PRODUCT ||--o{ LINE-ITEM : "ordered in"
```

### Gantt Chart
```mermaid
gantt
    title Project Timeline
    dateFormat YYYY-MM-DD
    section Design
    Requirements :done, d1, 2026-03-01, 5d
    Architecture  :active, a1, after d1, 7d
    section Development
    Implementation :crit, i1, after a1, 14d
    Testing :t1, after i1, 5d
```

## Theming & Styling

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#ff4785'}}}%%
flowchart LR
    A[Style Me] --> B[Dark Mode]
```

### Custom CSS Classes
```mermaid
flowchart TD
    classDef highlight fill:#f9f,stroke:#333,stroke-width:4px
    A --> B --> C
    B:::highlight
    class C highlight
```

## Workflow Integration

Use diagrams to document:
- **Architecture**: System components and data flow
- **Processes**: Business logic and decision trees  
- **Sequences**: API calls and user interactions
- **States**: Object lifecycle and transitions
- **Data Models**: ERD and class relationships

## Best Practices

1. Keep labels short and descriptive
2. Use subgraphs to group related nodes
3. Choose direction (TD/BT/LR/RL) based on content
4. Add styling for emphasis on key nodes
5. Include both light and dark mode compatibility

## Quick Reference

| Type | Keyword | Best For |
|------|---------|----------|
| Flow | `flowchart` | Decision trees, processes |
| Sequence | `sequenceDiagram` | API calls, interactions |
| State | `stateDiagram-v2` | Object lifecycle |
| Class | `classDiagram` | Type relationships |
| ER | `erDiagram` | Database schema |
| Gantt | `gantt` | Project timelines |
| Pie | `pie` | Distribution visualization |
