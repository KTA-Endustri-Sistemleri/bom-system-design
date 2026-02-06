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

## Cable System Technicals
- **Dynamic UI**: Use `set_query` for dependent filtering (Standard → Series → Rules).
- **Rule Engine**: Rules should be cached server-side to minimize DB hits during connection validation.
- **Auto-Generation**: Implemented in the Python controller of `Cable Specification` via `on_update` or triggered via custom button.
- **Integrity**: `Cable Core` rows must be linked by name or ID to prevent orphan connections when re-generating.
- **UX**: Fields should be toggled (Hidden/ReadOnly) based on active rules.

