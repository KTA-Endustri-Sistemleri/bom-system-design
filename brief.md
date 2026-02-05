# BOM Creator Application – Technical & Functional Brief

## 1. Purpose & Vision

BOM Creator is a standalone Frappe application designed to generate **deterministic, engineering-grade Bills of Materials (BOMs)** from structured product specifications.

Instead of manually editing BOM lines, users define:
- **Component libraries** (Connectors, Cables, Terminals, Accessories)
- **Logical connections** between components
- **Project-specific overrides** (e.g. cable length)

From this single source of truth, the system generates:
- ERPNext-compatible BOMs
- Visual wiring diagrams (Graphviz)
- Structured data suitable for manufacturing, QC, and documentation

The application is inspired by WireViz, but fully integrated into ERPNext’s data model and production workflows.

---

## 2. Core Design Principles

1. **Single Source of Truth**
   - Item Specs define what a component *is*
   - Build/Project defines how it is *used*

2. **Deterministic Output**
   - Same input → same BOM & diagram
   - Hash-based revisioning

3. **Library-Driven**
   - Items act as reusable component libraries
   - No duplication of specs per project

4. **UI-Assisted, Not UI-Dependent**
   - UI helps, but all logic is enforceable server-side

5. **Engineering-First**
   - Validation > convenience
   - Incorrect designs are blocked early

---

## 3. Application Scope

### Included
- Connector, Cable, Terminal specs (full-featured)
- BOM Build (project/spec document)
- Drag & drop BOM creator UI (Vue)
- Connection editor (table-based)
- Automatic BOM derivation
- Graphviz diagram generation (SVG/PNG)
- ERPNext BOM compatibility

### Explicitly Out of Scope (v1)
- Electrical simulation
- Live current/voltage calculations
- External PLM sync
- Cost rollups beyond standard BOM

---

## 4. Architecture Overview

### App Type
- **Standalone Frappe App**
- Not embedded in any other app

### Technologies
- Backend: Frappe Framework (Python)
- Frontend: Vue 3 (bundled, mounted in ERPNext Page)
- Diagram Engine: Graphviz (`dot`)
- Storage: ERPNext DocTypes + File attachments

---

## 5. Data Model

### 5.1 Item Library & Specs

Items are linked to exactly one spec type via `spec_role`.

#### Common Item Fields
- `spec_role` (Connector | Cable | Terminal | None)
- `spec_reference_doctype`
- `spec_reference_name`

---

### 5.2 Connector Spec

**Required**
- `family`
- `pin_count`
- `pin_labels` (child table: pin_no, label)

**Optional (ALL INCLUDED)**
- gender
- mounting
- orientation
- keying
- pitch_mm
- housing_part_number
- contact_part_number
- datasheet_url
- drawing_file
- rated_voltage_v
- rated_current_a
- ip_rating
- nc_label_value (default: N/C)

---

### 5.3 Cable Spec

**Required**
- gauge_mm2
- wirecount
- shielded
- color_code_standard
- core_colors (ordered child table)

**Optional (ALL INCLUDED)**
- cable_type
- outer_diameter_mm
- jacket_color
- jacket_material
- temperature_rating_c
- voltage_rating_v
- flame_rating
- is_twisted
- twist_pairs
- impedance_ohm
- drain_wire
- shield_type
- shield_coverage_pct
- manufacturer
- part_number
- datasheet_url
- uom_for_length (default: Meter)
- min_order_length_m
- cut_tolerance_mm

---

### 5.4 Terminal Spec

**Required**
- style
- terminal_type
- material_color

**Optional (ALL INCLUDED)**
- compatible_roles
- min_gauge_mm2
- max_gauge_mm2
- insulated
- insulation_color
- crimp_type
- heatshrink_required
- heatshrink_item
- recommended_tool
- part_number
- datasheet_url
- per_connection_qty
- per_end_qty

---

## 6. BOM Build (Project-Level Spec)

### 6.1 BOM Build (Main DocType)

Fields:
- target_item
- revision
- status (Draft / Released / Archived)
- hash
- generated_bom
- diagram_svg
- diagram_png
- notes

### 6.2 BOM Build Node (Child)

- node_id
- role
- item_code
- qty
- overrides_json

### 6.3 BOM Build Connection (Child)

- from_node
- from_pin
- from_label
- via_cable
- via_core
- to_node
- to_pin
- to_label
- signal_name
- net_id

---

## 7. UI Design

### ERPNext Page + Vue

**Step 1 – Nodes**
- Item picker (filtered by role)
- Node creation
- Spec summary view
- Override editor

**Step 2 – Connections**
- Table-based editor
- Pin dropdowns auto-generated
- Core colors auto-loaded
- N/C pins blocked

**Step 3 – Generate**
- Validate
- Generate BOM
- Generate Diagram
- Output links

---

## 8. Validation Rules

- Connector pin_count overflow forbidden
- Cable wirecount < used cores forbidden
- N/C labeled pins cannot be connected
- Shielded cables require termination awareness
- Duplicate core usage detected
- Gauge compatibility checked

---

## 9. BOM Derivation Logic

- Each Node → BOM item
- Cable qty derived from `length_m`
- Terminal quantities derived from connection count
- Accessories auto-added later via rules

---

## 10. Diagram Generation

- DOT generated server-side
- Graphviz renders SVG & PNG
- Nodes styled by role
- Edges labeled with core & signal

---

## 11. Deterministic Hashing

- Hash built from nodes, connections, overrides
- Same hash → same BOM revision
- Any change triggers new revision

---

## 12. Permissions & Governance

- Engineering: Create/Edit/Release
- Production: Read-only
- Released builds immutable

---

## 13. Future Extensions

- Accessory Spec
- Rules Engine
- Multi-level BOM grouping
- PDF work instructions
- Spec import/export

---

## 14. Non-Goals

- Manual BOM editing
- Free-form wiring
- Item duplication per project

---

## 15. Summary

BOM Creator replaces manual BOM editing with a **spec-driven, validated, and visual system** that is reproducible, auditable, and scalable.
