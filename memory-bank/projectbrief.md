# Project Brief: BOM Creator

BOM Creator is a standalone Frappe application designed to generate **deterministic, engineering-grade Bills of Materials (BOMs)** from structured product specifications.

## Business Purpose
The application replaces manual, error-prone BOM editing with a spec-driven, validated, and visual system. It ensures that engineering requirements (connectors, cables, terminals) are accurately translated into manufacturing data and visual documentation.

## Core Goals
- **Single Source of Truth**: Item specs define what a component is; BOM Build defines how it is used.
- **Expert Knowledge Base**: Rule-driven cable selection acts as a constraint solver, guiding users and preventing invalid configurations.
- **Deterministic Output**: Same inputs always result in the same BOM and wiring diagrams.

- **Engineering Validation**: Block incorrect designs early (e.g., pin count overflow, gauge mismatch).
- **ERP Integration**: Seamlessly generate ERPNext-compatible BOMs.

## Scope
### In-Scope
- Component libraries (Connector, Cable, Terminal specs).
- BOM Build engine (Revisioning, Hashing).
- Drag-and-drop Vue UI for BOM creation.
- Connection editor and Graphviz diagram generation.
- ERPNext BOM compatibility.

### Out-of-Scope (v1)
- Electrical simulation (current/voltage calculations).
- External PLM synchronization.
- Cost rollups beyond standard BOM.

## Key Stakeholders
- **Engineering**: Design and release BOMs.
- **Production**: Execute manufacturing based on released builds.
- **Quality Control**: Verify connections against generated diagrams.
