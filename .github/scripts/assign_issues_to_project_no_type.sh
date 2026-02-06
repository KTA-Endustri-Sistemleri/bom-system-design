set -euo pipefail

ORG="KTA-Endustri-Sistemleri"
REPO="bom-system-design"
PROJECT_TITLE="BOM System Redesign Roadmap"

PROJECT_ID=$(gh api graphql -f query='
query($org:String!) {
  organization(login:$org) {
    projectsV2(first:50) { nodes { id title } }
  }
}' -F org="$ORG" --jq ".data.organization.projectsV2.nodes[] | select(.title==\"$PROJECT_TITLE\") | .id" | head -n 1)

if [ -z "${PROJECT_ID:-}" ] || [ "$PROJECT_ID" = "null" ]; then
  echo "ERROR: Project not found: $PROJECT_TITLE under org $ORG"
  exit 1
fi

echo "Project ID: $PROJECT_ID"

# NOTE: Use `id` (GraphQL node id), NOT node_id
ISSUES=$(gh issue list -R "$ORG/$REPO" --limit 200 --state open --json number,id,title)

echo "$ISSUES" | jq -c '.[]' | while read -r issue; do
  NUM=$(echo "$issue" | jq -r .number)
  ISSUE_ID=$(echo "$issue" | jq -r .id)
  TITLE=$(echo "$issue" | jq -r .title)

  echo "Adding issue #$NUM to project: $TITLE"

  gh api graphql -f query='
mutation($project:ID!, $content:ID!) {
  addProjectV2ItemById(input:{projectId:$project, contentId:$content}) {
    item { id }
  }
}' -F project="$PROJECT_ID" -F content="$ISSUE_ID" >/dev/null 2>&1 || true
done

echo "DONE: issues added to project."
