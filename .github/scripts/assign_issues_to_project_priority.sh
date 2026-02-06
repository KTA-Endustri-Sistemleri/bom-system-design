set -euo pipefail

ORG="KTA-Endustri-Sistemleri"
REPO="bom-system-design"
PROJECT_TITLE="BOM System Redesign Roadmap"

echo "Org: $ORG"
echo "Repo: $ORG/$REPO"
echo "Project: $PROJECT_TITLE"

PROJECT_ID=$(gh api graphql -f query='
query($org:String!) {
  organization(login:$org) {
    projectsV2(first:50) { nodes { id title } }
  }
}' -F org="$ORG" --jq ".data.organization.projectsV2.nodes[] | select(.title==\"$PROJECT_TITLE\") | .id" | head -n 1)

[ -n "${PROJECT_ID:-}" ] && [ "$PROJECT_ID" != "null" ] || { echo "ERROR: Project not found"; exit 1; }
echo "Project ID: $PROJECT_ID"

FIELDS_JSON=$(gh api graphql -f query='
query($project:ID!) {
  node(id:$project) {
    ... on ProjectV2 {
      fields(first:50) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id
            name
            options { id name }
          }
        }
      }
    }
  }
}' -F project="$PROJECT_ID")

PRIORITY_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name=="Priority") | .id' | head -n 1)
[ -n "${PRIORITY_FIELD_ID:-}" ] && [ "$PRIORITY_FIELD_ID" != "null" ] || { echo "ERROR: Priority field not found"; exit 1; }

OPT_P0=$(echo "$FIELDS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name=="Priority") | .options[] | select(.name=="P0") | .id' | head -n 1)
OPT_P1=$(echo "$FIELDS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name=="Priority") | .options[] | select(.name=="P1") | .id' | head -n 1)
OPT_P2=$(echo "$FIELDS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name=="Priority") | .options[] | select(.name=="P2") | .id' | head -n 1)

echo "Priority mapping:"
echo "  critical(P0) -> $OPT_P0"
echo "  normal(P1)   -> $OPT_P1"
echo "  low(P2)      -> $OPT_P2"

ISSUES=$(gh issue list -R "$ORG/$REPO" --limit 200 --state open --json number,title,labels,id)

echo "$ISSUES" | jq -c '.[]' | while read -r issue; do
  NUM=$(echo "$issue" | jq -r .number)
  ISSUE_ID=$(echo "$issue" | jq -r .id)
  TITLE=$(echo "$issue" | jq -r .title)
  LABELS=$(echo "$issue" | jq -r '.labels[].name' 2>/dev/null || true)

  PRIO_OPT="$OPT_P1"
  if echo "$LABELS" | grep -q '^priority:critical$'; then PRIO_OPT="$OPT_P0"; fi
  if echo "$LABELS" | grep -q '^priority:low$'; then PRIO_OPT="$OPT_P2"; fi

  echo "== Issue #$NUM: add to project + set Priority =="

  # add to project (or fetch existing item id)
  ITEM_ID=$(gh api graphql -f query='
mutation($project:ID!, $content:ID!) {
  addProjectV2ItemById(input:{projectId:$project, contentId:$content}) {
    item { id }
  }
}' -F project="$PROJECT_ID" -F content="$ISSUE_ID" --jq '.data.addProjectV2ItemById.item.id' 2>/dev/null || true)

  if [ -z "${ITEM_ID:-}" ] || [ "$ITEM_ID" = "null" ]; then
    ITEM_ID=$(gh api graphql -f query='
query($project:ID!) {
  node(id:$project) {
    ... on ProjectV2 {
      items(first:200) {
        nodes { id content { ... on Issue { number } } }
      }
    }
  }
}' -F project="$PROJECT_ID" --jq ".data.node.items.nodes[] | select(.content.number==$NUM) | .id" | head -n 1)
  fi

  [ -n "${ITEM_ID:-}" ] && [ "$ITEM_ID" != "null" ] || { echo "WARN: No project item id for #$NUM"; continue; }

  # ✅ NO $opt variable. We embed the option id literal into the query.
  gh api graphql -f query="
mutation(\$project:ID!, \$item:ID!, \$field:ID!) {
  updateProjectV2ItemFieldValue(input:{
    projectId:\$project,
    itemId:\$item,
    fieldId:\$field,
    value:{ singleSelectOptionId:\"$PRIO_OPT\" }
  }) { projectV2Item { id } }
}" -F project="$PROJECT_ID" -F item="$ITEM_ID" -F field="$PRIORITY_FIELD_ID" >/dev/null

done

echo "DONE: Priority populated."
