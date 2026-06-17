#!/usr/bin/env bash
# Shows disk usage of everything matched by .stignore, without double-counting.
# Usage: stignore-size.sh [root_dir]

ROOT="${1:-.}"
ROOT="${ROOT%/}"
STIGNORE="$ROOT/.stignore"

if [[ ! -f "$STIGNORE" ]]; then
  echo "No .stignore found in $ROOT"
  exit 1
fi

mapfile -t PATTERNS < <(grep -v '^\s*//' "$STIGNORE" | grep -v '^\s*$')

# Collect all raw matches, sorted so parents come before children
mapfile -t ALL_PATHS < <(
  for pat in "${PATTERNS[@]}"; do
    find "$ROOT" -name "$pat" 2>/dev/null
  done | sort -u
)

# Prune: skip any path whose parent was already counted
declare -a PRUNED
declare -a SEEN_PARENTS
for path in "${ALL_PATHS[@]}"; do
  skip=0
  for parent in "${SEEN_PARENTS[@]}"; do
    if [[ "$path" == "$parent"/* ]]; then
      skip=1; break
    fi
  done
  if [[ $skip -eq 0 ]]; then
    PRUNED+=("$path")
    [[ -d "$path" ]] && SEEN_PARENTS+=("$path")
  fi
done

echo "Scanning $ROOT for stignore matches..."
echo

TOTAL=0
for path in "${PRUNED[@]}"; do
  size_bytes=$(du -sb "$path" 2>/dev/null | cut -f1)
  size_human=$(du -sh "$path" 2>/dev/null | cut -f1)
  TOTAL=$((TOTAL + size_bytes))
  printf "  %8s  %s\n" "$size_human" "${path#$ROOT/}"
done

echo
echo "  Total: $(numfmt --to=iec-i --suffix=B "$TOTAL")"
