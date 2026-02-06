# Data Model: BOM Creator

This file defines the persistent database structure for the application.

## Custom DocTypes

### 1. Connector Spec
- **Family**: (Link) Product family.
- **Pin Count**: (Int) Total number of Pins.
- **Pin Labels**: (Table) Child table with `pin_no` and `label`.
- **Metadata**: Gender, Mounting, Orientation, Keying, Pitch, etc.

### 2. Cable Spec
- **Gauge (mm2)**: (Float) Wire thickness.
- **Wirecount**: (Int) Number of cores.
- **Shielded**: (Check) Is the cable shielded?
- **Core Colors**: (Table) Ordered child table.
- **Metadata**: Outer Diameter, Jacket Material, Temperature Rating, Voltage Rating, etc.

### 3. Terminal Spec
- **Style**: (Select) Ring, Spade, Pin, etc.
- **Terminal Type**: (Select).
- **Material/Color**: (Data).
- **Metadata**: Compatiable roles, Min/Max gauge, Insulated, Crimp type, etc.

### 4. BOM Build
- **Target Item**: (Link -> Item) The final assembly item.
- **Revision**: (Data) Revision identifier.
- **Status**: (Select) Draft, Released, Archived.
- **Hash**: (Data) Deterministic hash of the build data.
- **Generated BOM**: (Link -> BOM) Reference to the ERPNext BOM.
- **Diagrams**: (Attach) SVG and PNG files.

### 5. BOM Build Node (Child Table)
- **Node ID**: (Data) Unique identifier within the build (e.g., J1, W1).
- **Role**: (Select) Connector, Cable, Terminal.
- **Item Code**: (Link -> Item).
- **Overrides JSON**: (Small Text) Stores project-specific spec overrides.

### 6. BOM Build Connection (Child Table)
- **From Node**: (Link -> Node).
- **From Pin**: (Data).
- **Via Cable**: (Link -> Node).
- **Via Core**: (Data).
- **To Node**: (Link -> Node).
- **To Pin**: (Data).
- **Signal Name**: (Data).
- **Net ID**: (Data).

## Naming Conventions
- All custom DocTypes will be prefixed with `BOM Creator`.
- Item Codes should use the existing ERPNext `Item` DocType.
