#!/bin/bash
set -e

SKILLS_DIR="/home/pi-web/.pi/agent/skills"

# Prefetch skill repositories if SKILL_REPOSITORIES is set
if [ -n "$SKILL_REPOSITORIES" ]; then
  mkdir -p "$SKILLS_DIR"
  echo "Prefetching skill repositories..."
  
  IFS=' ' read -ra REPOS <<< "$SKILL_REPOSITORIES"
  for REPO_URL in "${REPOS[@]}"; do
    [ -z "$REPO_URL" ] && continue
    
    # Extract repo name from URL (last component before .git)
    REPO_NAME=$(basename "$REPO_URL" .git)
    TARGET_DIR="$SKILLS_DIR/$REPO_NAME"
    
    if [ -d "$TARGET_DIR/.git" ]; then
      echo "  Updating $REPO_NAME..."
      git -C "$TARGET_DIR" pull --ff-only 2>/dev/null || echo "  Warning: could not update $REPO_NAME"
    else
      echo "  Cloning $REPO_NAME..."
      git clone --depth 1 "$REPO_URL" "$TARGET_DIR" 2>/dev/null || echo "  Warning: could not clone $REPO_URL"
    fi
  done
  
  echo "Skill prefetch complete."
fi

# Launch session daemon and web server
exec bash -c 'trap "kill 0" EXIT; pi-web-sessiond & sleep 1 && pi-web-server & wait'
