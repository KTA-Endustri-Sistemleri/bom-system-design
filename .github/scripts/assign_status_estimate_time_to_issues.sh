set -euo pipefail

ORG="KTA-Endustri-Sistemleri"
REPO="bom-system-design"
PROJECT_TITLE="BOM System Redesign Roadmap"

echo "Org: $ORG"
echo "Repo: $ORG/$REPO"
echo "Project: $PROJECT_TITLE"

# Find project ID
PROJECT_ID=$(gh api graphql -f query='
query($org:String!) {
  organization(login:$org) {
    projectsV2(first:50) { nodes { id title } }
  }
}' -F org="$ORG" --jq ".data.organization.projectsV2.nodes[] | select(.title==\"$PROJECT_TITLE\") | .id" | head -n 1)

[ -n "${PROJECT_ID:-}" ] && [ "$PROJECT_ID" != "null" ] || { echo "ERROR: Project not found"; exit 1; }
echo "Project ID: $PROJECT_ID"

# Fetch fields (common + single select options)
FIELDS_JSON=$(gh api graphql -f query='
query($project:ID!) {
  node(id:$project) {
    ... on ProjectV2 {
      fields(first:50) {
        nodes {
          ... on ProjectV2FieldCommon { id name }
          ... on ProjectV2SingleSelectField {
            id name
            options { id name }
          }
        }
      }
    }
  }
}' -F project="$PROJECT_ID")

# Field IDs
STATUS_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name=="Status") | .id' | head -n 1)
SIZE_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name=="Size") | .id' | head -n 1)
EST_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name=="Estimate") | .id' | head -n 1)

[ -n "${STATUS_FIELD_ID:-}" ] && [ "$STATUS_FIELD_ID" != "null" ] || { echo "ERROR: Status field not found"; exit 1; }
[ -n "${EST_FIELD_ID:-}" ] && [ "$EST_FIELD_ID" != "null" ] || { echo "ERROR: Estimate field not found"; exit 1; }

# Size optional
if [ -z "${SIZE_FIELD_ID:-}" ] || [ "$SIZE_FIELD_ID" = "null" ]; then
  echo "WARN: Size field not found; will not set Size."
  SIZE_FIELD_ID=""
fi

# Helper: option id for a single select field
opt() {
  local field="$1" name="$2"
  echo "$FIELDS_JSON" | jq -r --arg f "$field" --arg n "$name" '
    .data.node.fields.nodes[]
    | select(.name==$f)
    | .options[]?
    | select(.name==$n)
    | .id' | head -n 1
}

# Status option IDs
ST_BACKLOG=$(opt "Status" "Backlog")
ST_READY=$(opt "Status" "Ready")
ST_INPROG=$(opt "Status" "In progress")
ST_INREV=$(opt "Status" "In review")
ST_DONE=$(opt "Status" "Done")

echo "Status options: Backlog=$ST_BACKLOG Ready=$ST_READY InProgress=$ST_INPROG InReview=$ST_INREV Done=$ST_DONE"

# Size option IDs (if exists)
SZ_XS=""; SZ_S=""; SZ_M=""; SZ_L=""; SZ_XL=""
if [ -n "$SIZE_FIELD_ID" ]; then
  SZ_XS=$(opt "Size" "XS")
  SZ_S=$(opt "Size" "S")
  SZ_M=$(opt "Size" "M")
  SZ_L=$(opt "Size" "L")
  SZ_XL=$(opt "Size" "XL")
  echo "Size options: XS=$SZ_XS S=$SZ_S M=$SZ_M L=$SZ_L XL=$SZ_XL"
fi

# Issues (all states so closed -> Done)
ISSUES=$(gh issue list -R "$ORG/$REPO" --limit 200 --state all --json number,title,labels,id,assignees,state,milestone)

echo "$ISSUES" | jq -c '.[]' | while read -r issue; do
  NUM=$(echo "$issue" | jq -r .number)
  ISSUE_ID=$(echo "$issue" | jq -r .id)
  STATE=$(echo "$issue" | jq -r .state)  # OPEN/CLOSED
  ASSIGNEE_COUNT=$(echo "$issue" | jq -r '.assignees | length')
  MILESTONE_TITLE=$(echo "$issue" | jq -r '.milestone.title // ""')
  LABELS=$(echo "$issue" | jq -r '.labels[].name' 2>/dev/null || true)

  # ---- STATUS rule ----
  STATUS_OPT="$ST_BACKLOG"
  if [ "$STATE" = "CLOSED" ]; then
    STATUS_OPT="$ST_DONE"
  else
    if [ "$ASSIGNEE_COUNT" -gt 0 ]; then
      STATUS_OPT="$ST_INPROG"
    elif [ -n "$MILESTONE_TITLE" ]; then
      STATUS_OPT="$ST_READY"
    else
      STATUS_OPT="$ST_BACKLOG"
    fi
  fi

  # ---- ESTIMATE rule ----
  EST=2
  if echo "$LABELS" | grep -q '^size:XS$'; then EST=1; fi
  if echo "$LABELS" | grep -q '^size:S$'; then EST=2; fi
  if echo "$LABELS" | grep -q '^size:M$'; then EST=3; fi
  if echo "$LABELS" | grep -q '^size:L$'; then EST=5; fi
  if echo "$LABELS" | grep -q '^size:XL$'; then EST=8; fi

  if ! echo "$LABELS" | grep -q '^size:'; then
    if echo "$LABELS" | grep -q '^type:frontend$'; then EST=3; fi
    if echo "$LABELS" | grep -q '^type:backend$'; then EST=2; fi
    if echo "$LABELS" | grep -q '^type:data-model$'; then EST=2; fi
    if echo "$LABELS" | grep -q '^type:validation$'; then EST=2; fi
    if echo "$LABELS" | grep -q '^type:generator$'; then EST=5; fi
    if echo "$LABELS" | grep -q '^type:diagram$'; then EST=5; fi
    if echo "$LABELS" | grep -q '^type:devops$'; then EST=1; fi
  fi

  # ---- SIZE from EST (optional) ----
  SIZE_OPT=""
  if [ -n "$SIZE_FIELD_ID" ]; then
    case "$EST" in
      1) SIZE_OPT="$SZ_XS" ;;
      2) SIZE_OPT="$SZ_S" ;;
      3) SIZE_OPT="$SZ_M" ;;
      5) SIZE_OPT="$SZ_L" ;;
      8) SIZE_OPT="$SZ_XL" ;;
      *) SIZE_OPT="" ;;
    esac
  fi

  echo "== #$NUM [$STATE] -> StatusOpt=$STATUS_OPT Estimate=$EST SizeOpt=${SIZE_OPT:-n/a} =="

  # Add issue to project (or fetch existing item id)
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
      items(first:200) { nodes { id content { ... on Issue { number } } } }
    }
  }
}' -F project="$PROJECT_ID" --jq ".data.node.items.nodes[] | select(.content.number==$NUM) | .id" | head -n 1)
  fi

  [ -n "${ITEM_ID:-}" ] && [ "$ITEM_ID" != "null" ] || { echo "WARN: No project item id for #$NUM"; continue; }

  # 1) Update Status (literal embed to avoid ID/String drama)
  gh api graphql -f query="
mutation(\$project:ID!, \$item:ID!, \$field:ID!) {
  updateProjectV2ItemFieldValue(input:{
    projectId:\$project,
    itemId:\$item,
    fieldId:\$field,
    value:{ singleSelectOptionId:\"$STATUS_OPT\" }
  }) { projectV2Item { id } }
}" -F project="$PROJECT_ID" -F item="$ITEM_ID" -F field="$STATUS_FIELD_ID" >/dev/null

  # 2) Update Estimate (number)
  gh api graphql -f query='
mutation($project:ID!, $item:ID!, $field:ID!, $val:Float!) {
  updateProjectV2ItemFieldValue(input:{
    projectId:$project,
    itemId:$item,
    fieldId:$field,
    value:{ number:$val }
  }) { projectV2Item { id } }
}' -F project="$PROJECT_ID" -F item="$ITEM_ID" -F field="$EST_FIELD_ID" -F val="$EST" >/dev/null

  # 3) Update Size (optional)
  if [ -n "$SIZE_FIELD_ID" ] && [ -n "${SIZE_OPT:-}" ] && [ "$SIZE_OPT" != "null" ]; then
    gh api graphql -f query="
mutation(\$project:ID!, \$item:ID!, \$field:ID!) {
  updateProjectV2ItemFieldValue(input:{
    projectId:\$project,
    itemId:\$item,
    fieldId:\$field,
    value:{ singleSelectOptionId:\"$SIZE_OPT\" }
  }) { projectV2Item { id } }
}" -F project="$PROJECT_ID" -F item="$ITEM_ID" -F field="$SIZE_FIELD_ID" >/dev/null
  fi

done

echo "DONE: Status + Estimate (+Size) updated."
