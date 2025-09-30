# BOM System Design Draft

![Status](https://img.shields.io/badge/status-draft-orange)

ERPNext **Bill of Materials (BOM) design** for automatically resolving the relationships between **Cables, Terminals, and Moulds**.  
This is currently in the **concept/design phase** and will later be extended into a full ERPNext application.

## 🎯 Goal
- User only enters item codes in the BOM.
- The system resolves relationships and automatically determines the correct **operation + workstation** combination.
- Eliminates manual linking and reduces error risk.

## 🗂 Core Components
- **Moulds (KL-XXXX):** Can support multiple terminals, can be assigned to multiple workstations.
- **Terminals (100-Terminals):** Contain stripping values, can link to multiple cables and moulds.
- **Cables (200-Cables & Wires):** Contain crimp height information, can link to multiple terminals.

## 🔗 Relationships
- Mould ↔ Terminal (**many-to-many**)  
- Terminal ↔ Cable (**many-to-many**)  
- Mould ↔ Workstation (**many-to-many**)  

## ⚙️ Workflow
1. User selects any item (Cable / Terminal / Mould).
2. System narrows down relationships to find the **single valid combination**.
3. Workstation assignment via mould:
   - If only one workstation → auto-assign.  
   - If multiple → user selects.  

## ✅ Benefits
- Less manual linking
- Reduced error rate
- Cleaner **Job Card** interface
- Deterministic mapping → ensures automation

---

## 🚀 Milestones
### Milestone 1: Modeling
- [ ] Define DocTypes (Mould, Terminal, Cable)
- [ ] Define many-to-many relationship tables

### Milestone 2: BOM Integration
- [ ] Add `custom_mould` field to BOM Operation
- [ ] Hook: Auto-mapping during BOM save

### Milestone 3: Operation & Workstation
- [ ] Workstation selection algorithm (auto or user choice)
- [ ] Unified operation line output

### Milestone 4: Testing & Validation
- [ ] Test with dummy data (C-0001, T-0001, KL-0001)
- [ ] Verify operation output in Job Card

---

## 📌 Status
This repository is in the **design/draft phase**.  
Boilerplate code and JSON files will be added in later milestones.
