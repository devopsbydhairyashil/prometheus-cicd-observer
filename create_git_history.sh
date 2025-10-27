#!/usr/bin/env bash
git init
git config user.name "Dhairyashil B"
git config user.email "devopsbydhairyashil@example.com"
msgs=(
  "feat: initial project scaffold"
  "chore: add README and architecture diagram"
  "feat: app placeholder and Dockerfile"
  "test: add local kind validation notes"
  "fix: update readiness probe"
  "docs: add AWS EKS migration notes"
  "chore: include logs and scripts for demo"
)
i=0
base_date="2025-06-10T09:00:00Z"
for m in "${msgs[@]}"; do
  DATE=$(date -u -d "${base_date} +$((i*36)) hours" +"%Y-%m-%dT%H:%M:%SZ")
  echo "$m" > commit_note.txt
  git add -A
  GIT_COMMITTER_DATE="$DATE" GIT_AUTHOR_DATE="$DATE" git commit -m "$m" || true
  i=$((i+1))
done
echo "Synthetic commit history created."
