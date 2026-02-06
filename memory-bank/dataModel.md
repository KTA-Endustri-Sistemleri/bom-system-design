# Data Model: BOM Creator

This file defines the persistent database structure for the application.

## Custom DocTypes

### 1. Connector Spec
- **Family**: (Link) Product family.
- **Pin Count**: (Int) Total number of Pins.
- **Pin Labels**: (Table) Child table with `pin_no` and `label`.
- **Metadata**: Gender, Mounting, Orientation, Keying, Pitch, etc.

### 2. Cable Specification (Refined)
The system uses a rule-driven architecture for cables.

#### Master Data
- **Cable Standard**: (L) UL, IEC, ISO, SAE. Domain-specific (Energy, Automotive, etc).
- **Cable Series**: (L) AWM, THHN, LiYCY, etc. Linked to Standard. Includes voltage and temp limits.
- **Cable Property Option**: (D) Generic dictionary for insulation, core counts, shields, etc. Used to avoid hardcoding dropdowns.
- **Cable Rule**: (M) Logic engine defining allowed combinations (e.g., specific Series allows only specific Core Counts).

#### Color System
- **Cable Color**: (D) Library of RD, BU, BK, etc. with Hex codes and stripe rules.
- **Color Standard**: (L) DIN 47100, IEC, UL General, etc.
- **Color Sequence**: (M) Maps a Color Standard and Core Count to a specific ordered list of colors.
- **Color Sequence Row**: (C) Child of Sequence. Order index, Color, Stripe.

#### Item Profile
- **Cable Specification**: (Linked to Item)
  - Standard, Series, Core Count, Cross Section, Insulation, Shield.
  - Temperature Class, Color Standard.
  - Generation Status (Pending/Generated).

#### Generated Cores
- **Cable Core**: (Child of Cable Specification)
  - Auto-generated based on Color Sequence.
  - Core No, Color, Stripe, Pair ID, Function, Group Shield.


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
