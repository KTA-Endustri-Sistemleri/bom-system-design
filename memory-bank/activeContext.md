# Active Context: BOM Creator

## Current Status
We are in the initial setup phase. The project vision and technical specifications have been defined in `brief.md`.

## Current Focus
- Establishing the rule-driven Cable Configuration & Core Identification System.
- Preparing for the implementation of core DocTypes with validation rules and auto-generation logic.
- Finalizing the naming series strategy for BOM Builds.


## Recent Decisions
- **Standalone App**: The application will be a standalone Frappe app, not embedded in ERPNext core, to allow for faster iteration and specific engineering logic.
- **Vue Integration**: Vue 3 will be used for the complex drag-and-drop BOM creator UI, hosted within an ERPNext Page.
- **Graphviz**: WireViz-inspired diagrams will be generated using server-side Graphviz (`dot`).

## Pending Issues / Decisions
- Finalizing the naming series strategy for BOM Builds.
- Defining the exact triggers for revision hashing.
- Mapping out the "Accessory Spec" and Rules Engine for v2.
