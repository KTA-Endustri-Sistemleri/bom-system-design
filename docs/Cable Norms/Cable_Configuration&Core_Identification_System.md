# Cable Configuration & Core Identification System

## Functional + Technical Implementation Brief

---

## 1. Purpose

Design a rule-driven cable configuration system inside ERPNext/Frappe that:

* Prevents invalid cable definitions
* Guides the user step-by-step via constrained selections
* Automatically generates core colors
* Supports harness/pin mapping in the future
* Works as a reusable engineering knowledge base

The system must behave like a **constraint solver**, not a free-form product card.

---

## 2. Conceptual Model

A cable is not a single object.
It consists of:

**Cable Definition (logical specification)**
+
**Generated Core Instances (physical conductors)**

```
Cable Item
 ├─ Standard Rules
 ├─ Construction Properties
 ├─ Regulatory Properties
 └─ Generated Cores (dynamic)
        ├─ Color
        ├─ Stripe
        ├─ Pair
        ├─ Function
```

---

## 3. Data Architecture

### 3.1 Master Data

#### DocType: Cable Standard

Defines governing authority.

Fields:

* name (UL, IEC, ISO, SAE)
* domain (energy, control, data, automotive)
* description

---

#### DocType: Cable Series

Sub-family under a standard.

Fields:

* standard (Link → Cable Standard)
* series_code (e.g. AWM, THHN, LiYCY, Cat6)
* voltage_class
* temp_min
* temp_max

---

#### DocType: Cable Property Option

Generic selectable values (dictionary table).

Fields:

* property_name (core_count, insulation, shield, etc.)
* value
* label
* sort_order

This table prevents hardcoding dropdowns in UI.

---

#### DocType: Cable Rule

Core rule engine.

Fields:

* parent_property
* parent_value
* target_property
* allowed_values (Table MultiSelect → Cable Property Option)
* is_locking_rule (bool)
* priority

Purpose:
Defines allowed combinations dynamically.

---

## 4. Color System

### 4.1 Color Library

#### DocType: Cable Color

Fields:

* code (RD, BU, BK)
* name
* hex
* stripe_allowed (bool)

---

### 4.2 Color Standard

#### DocType: Color Standard

Fields:

* name (DIN 47100, IEC, UL General, Profinet)

---

### 4.3 Color Sequence

#### DocType: Color Sequence

Defines automatic core color generation.

Fields:

* color_standard
* core_count
* sequence (Child table)

Child Table: Color Sequence Row

* order_index
* color
* stripe

---

## 5. Cable Item Profile

#### DocType: Cable Specification

(Linked to Item)

Fields:

* item
* standard
* series
* core_count
* cross_section
* insulation
* shield
* temperature_class
* color_standard
* generation_status

---

## 6. Generated Cores

#### DocType: Cable Core

Child of Cable Specification

Fields:

* core_no
* color
* stripe
* pair_id
* function
* group_shield

Auto-generated — not manually created initially.

---

## 7. System Behaviour

### 7.1 Selection Flow

1. User selects Standard
2. System filters Series
3. Series filters construction properties
4. Core count triggers color generation
5. System validates entire combination

Invalid combinations must never be savable.

---

### 7.2 Core Auto Generation

Trigger:

```
on_update: core_count OR color_standard
```

Process:

```
1. Fetch color sequence
2. Delete existing cores
3. Create N Cable Core rows
4. Assign colors in order
```

---

### 7.3 Validation Engine

Runs on save:

```
for each property:
    fetch matching rules
    verify allowed set
    raise error if invalid
```

---

## 8. UI Requirements

### Form Behavior

* Dependent dropdown filtering (query filters)
* Hidden irrelevant fields
* Locked fields when rule forces value
* Preview table showing generated cores

### UX Goal

User should never need a catalog.

---

## 9. Extensibility (Future)

Planned modules supported by this design:

* Wire harness builder
* Connector pin mapping
* Automatic BOM generation
* Diagram export (Graphviz/WireViz)
* Manufacturing instructions
* Label printing

---

## 10. Technical Notes (Frappe)

Recommended Implementation:

* Property options NOT as Select fields
* Always Link → Option tables
* Rules cached server-side
* Core generation in Python controller
* UI filtering via set_query
* Validation in validate()

---

## 11. Success Criteria

The system is considered complete when:

* Users cannot create invalid cables
* Core colors auto-populate
* Standard logic is data-driven (no code edits required)
* New standards added without code change
* Supports >500 cable types without UI complexity increase

---

END OF DOCUMENT
