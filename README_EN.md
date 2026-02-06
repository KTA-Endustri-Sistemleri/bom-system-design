# BOM System Design

A visual wire harness design and manufacturing BOM generator running inside ERPNext.

This is NOT a traditional ERP BOM entry tool.
Engineers design a harness by placing components and connecting pins.
The system validates the design, generates diagrams and exports a production BOM.

---

## Purpose

Complex wiring harnesses cannot be created as line-by-line ERP entries.

The system models:

- Connectors
- Cables
- Terminals
- Splices

Result:
- Graphviz diagram
- Manufacturable BOM
- Verified connectivity

---

## Core Concepts

### Spec Driven Items
Each item contains engineering knowledge.

### Connection Graph
The system stores a connectivity graph, not a list.

### Validation Engine
Live engineering checks during design.

### Diagram Generator
Automatic schematic generation via Graphviz.

### BOM Generator
Exports ERPNext manufacturing BOM.

---

## Workflow

1) Place components
2) Connect pins
3) Validate
4) Generate diagram
5) Export BOM

---

## Architecture

Frontend: Vue Canvas  
Backend: Frappe  
Engine: Graph + validation  
Output: Graphviz + ERPNext

---

## Not This

Not an ERP BOM editor  
Not a rule engine  
Not production routing planner

This is an engineering design tool.

---

See: MILESTONES_EN.md