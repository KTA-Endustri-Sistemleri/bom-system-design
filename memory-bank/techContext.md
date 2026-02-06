# Tech Context: BOM Creator

## Technical Stack
- **Framework**: Frappe Framework (Python/MariaDB).
- **Frontend**: Vue 3 (bundled with Vite), mounted in an ERPNext Page.
- **Diagram Engine**: Graphviz (`dot` command-line utility).
- **Database**: MariaDB.

## Environment Requirements
- **Server Dependencies**: `graphviz` must be installed on the system path.
- **Python**: Standard Frappe environment requirements.
- **Node.js**: Required for building the Vue assets.

## Deployment Rules
- **Migrations**: Always run `bench migrate` after DocType changes.
- **Assets**: Run `bench build --app bom_creator` to compile Vue components.
- **Background Jobs**: Use Frappe's `enqueue` for long-running diagram generation tasks.

## Naming Conventions
- DocTypes: `BOM Creator [Name]` (e.g., `BOM Creator Connector Spec`).
- Fields: Snake_case.
- Methods: Descriptive, following standard Python/Frappe patterns.
