# Product Context: BOM Creator

BOM Creator is designed for engineering and manufacturing environments where complex wiring harnesses and assemblies are produced.

## User Workflows

### Engineering Design Workflow
1. **Define Library**: Engineers add Item codes for Connectors, Cables, and Terminals.
2. **Cable Specification**:
   - Select **Standard** & **Series**.
   - Fill construction properties (Core Count, Insulation, etc) guided by the **Constraint Solver** (Rules).
   - Once validated, the system **Auto-Generates Core Colors** based on the selected Color Standard.
3. **Build Assembly**: Using the Vue UI, engineers select components (Nodes) and define their relationships.
4. **Define Connections**: Table-based entry of pin-to-pin wiring using specific cable cores.
5. **Validation**: The system checks for errors (e.g., trying to use more cores than a cable has, or invalid property combinations).
6. **Release**: Once validated, the build is hashed and released, generating an ERPNext BOM and a wiring diagram.


### Production Workflow
1. **Access Released Build**: Production staff view the released BOM and wiring diagram.
2. **Manufacturing**: Staff follow the visual diagram and BOM to assemble the harness.
3. **Quality Control**: QC uses the diagram to verify every connection.

## Operational Environment
- **Shop Floor**: Accessed via tablets or PCs near assembly benches. 
- **High Stakes**: Incorrect wiring leads to costly rework or equipment damage. Deterministic output is critical.

## Performance & Reliability
- **Diagram Generation**: Must be fast enough for real-time preview during design.
- **Data Integrity**: Historical revisions must remain accessible even if library items change later.
