# System Patterns: BOM Creator

## Architecture Overview
BOM Creator follows the Frappe Framework's MVC pattern with a specialized Vue-based designer.

```mermaid
flowchart TD
    UI[Vue 3 Designer] <--> API[Frappe API]
    API <--> DB[(MariaDB)]
    API --> GV[Graphviz Generator]
    GV --> SVG[SVG Diagram]
    API --> BOM[ERPNext BOM Creator]
```

## Core Design Patterns

### Spec-Driven Items
Items in ERPNext are enriched with "Spec" DocTypes.
- **Spec Role**: Determines if an Item is a Connector, Cable, or Terminal.
- **Validation**: Server-side hooks check Spec data whenever a BOM Build is saved.

### Deterministic Revisioning
- **Hashing**: A SHA-256 hash is generated from the JSON representation of nodes and connections.
- **Immutability**: Once a BOM Build is "Released," it cannot be edited. Any changes require a new revision.

### Data Model Hierarchy
1. **BOM Build**: The parent document.
2. **BOM Build Node**: Child table representing instances of items (Connectors, Cables).
3. **BOM Build Connection**: Child table representing the wiring logic.

## Logic Flows

### Cable Configuration Logic
The system behaves as a **Constraint Solver**.
1. **Selection Flow**:
   - Standard filters compliant Series.
   - Series filters allowed Properties (Core Count, Insulation, etc) via `Cable Rule`.
   - UI locks or hides fields when rules force specific values.
2. **Validation Engine** (Run on `validate()`):
   - Fetches all `Cable Rule` records matching the current selection.
   - Verifies that all selected properties are within the allowed sets.
   - Raises a validation error for invalid combinations.

### Core Auto-Generation
Triggered when `core_count` or `color_standard` changes in `Cable Specification`.
1. **Fetch**: Retrieve the matching `Color Sequence`.
2. **Purge**: Delete existing `Cable Core` children.
3. **Generate**: Create $N$ new `Cable Core` rows.
4. **Sequence**: Map colors and stripes based on the sequence library.
5. **Status**: Update generation status to "Generated".

### BOM Generation
1. Validate all connections.
2. Aggregate Node quantities.
3. Calculate Cable lengths based on connection data or overrides.
4. Derive Terminal quantities (Qty = 1 per connected pin).
5. Create/Update standard ERPNext BOM.
6. **Cable Mapping**: Links `BOM Build Connection` directly to `Cable Core` instances for precise harness mapping.

### Diagram Generation
1. Parse `BOM Build Connection` table.
2. Generate DOT language script.
3. Call `dot` binary to render SVG.
4. Store SVG in File Manager and link to BOM Build.


