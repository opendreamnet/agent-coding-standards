#!/usr/bin/env bash
set -Eeuo pipefail

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "Required command '$1' was not found in PATH."
}

for cmd in git git-cliff gh tr; do
  need "$cmd"
done

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) \
  || die "Run this script from inside a Git repository."

cd "$repo_root"

branch=$(git symbolic-ref --quiet --short HEAD) \
  || die "You are in detached HEAD state. Switch to a branch before releasing."

[[ -z "$(git status --porcelain)" ]] \
  || die "The working tree is not clean. Commit or stash your changes first."

git remote get-url origin >/dev/null 2>&1 \
  || die "The 'origin' remote does not exist."

gh auth status >/dev/null 2>&1 \
  || die "GitHub CLI is not authenticated. Run 'gh auth login'."

gh repo view --json nameWithOwner >/dev/null 2>&1 \
  || die "GitHub CLI could not identify the current GitHub repository."

version=$(git-cliff --no-exec --bumped-version | tr -d '\r\n') \
  || die "git-cliff could not calculate the next version."

[[ -n "$version" ]] || die "git-cliff returned an empty version."

# Ensure the version has exactly one leading "v".
version="v${version#v}"

git check-ref-format "refs/tags/$version" >/dev/null \
  || die "The calculated version is not a valid tag name: $version"

if git show-ref --verify --quiet "refs/tags/$version"; then
  die "The local tag '$version' already exists."
fi

if ! remote_tag=$(git ls-remote --refs origin "refs/tags/$version"); then
  die "Could not check tags on origin."
fi
[[ -z "$remote_tag" ]] || die "The remote tag '$version' already exists."

if ! remote_branch=$(git ls-remote --heads origin "refs/heads/$branch"); then
  die "Could not check branches on origin."
fi
[[ -n "$remote_branch" ]] || die "The branch origin/$branch does not exist."

release_notes=$(git-cliff \
  --no-exec \
  --unreleased \
  --tag "$version" \
  --strip header) || die "Could not generate the release notes."

[[ -n "${release_notes//[[:space:]]/}" ]] \
  || die "There are no release notes to publish. No changes will be made."

printf 'Repository: %s\nBranch:     %s\nVersion:    %s\n\n' \
  "$(gh repo view --json nameWithOwner --jq .nameWithOwner)" \
  "$branch" \
  "$version"
printf '%s\n\n' "Release notes:" "$release_notes"

[[ -t 0 ]] || die "An interactive terminal is required to confirm the release."

read -r -p "Generate the CHANGELOG, create the tag, and publish the release? [y/N] " answer
case "$answer" in
  y|Y|yes|YES|Yes) ;;
  *) printf 'Cancelled; no changes were made.\n'; exit 0 ;;
esac

if [[ -f CHANGELOG.md ]]; then
  git-cliff --no-exec --unreleased --tag "$version" \
    --prepend CHANGELOG.md \
    || die "Failed to update CHANGELOG.md."
else
  git-cliff --no-exec --unreleased --tag "$version" \
    --output CHANGELOG.md \
    || die "Failed to create CHANGELOG.md."
fi

git add -- CHANGELOG.md

if git diff --cached --quiet -- CHANGELOG.md; then
  die "CHANGELOG.md did not change. No commit or release will be created."
fi

git commit -m "chore(release): $version"
git tag -a "$version" -m "Release $version"

git push origin "HEAD:refs/heads/$branch" "refs/tags/$version" \
  || die "The push failed. Check the local and remote state before running the script again."

if ! printf '%s\n' "$release_notes" |
  gh release create "$version" \
    --verify-tag \
    --title "$version" \
    --notes-file -
then
  die "Could not confirm that the release was created. Check 'gh release view $version' before retrying."
fi

gh release view "$version" --json tagName,url