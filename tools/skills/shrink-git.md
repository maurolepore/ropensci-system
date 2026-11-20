---
name: Shrink a Git repository
about: Move pkgdown docs to gh-pages and purge docs/ from Git history
type: Skill
---
# Shrink a Git repository

Shrink a Git repository that is large because a generated `docs/` directory (the pkgdown website) is committed to the tree and its history. Move the website to a `gh-pages` branch and purge `docs/` from the entire history. Do not push or mutate any remote: produce local changes plus the exact commands for the human to review and run.

## 1. Confirm where the size is

- `du -sh .git docs` - confirm `docs/` dominates the working tree and `.git/` is large.
- `git count-objects -vH` - record the current packed size for the before/after report.

## 2. Move the website off the default branch

- In R run `usethis::use_pkgdown_github_pages()` to configure pkgdown to build into a `gh-pages` branch and point GitHub Pages at it; commit the config changes it makes.
- Stop tracking the generated site: `git rm -r --cached docs`, add `docs/` to `.gitignore`, and commit.

Removing `docs/` from the working tree alone does NOT shrink `.git/` - the blobs remain in history. Step 4 is required.

## 3. Back up before rewriting history

- Make a complete backup, e.g. `git clone --mirror <repo> <repo>-backup` or `git bundle create ../repo-backup.bundle --all`. Verify the backup exists before continuing.

## 4. Purge `docs/` from all history

- Install [git-filter-repo](https://github.com/newren/git-filter-repo) and run `git filter-repo --path docs/ --invert-paths`. Prefer a fresh clone; `--force` overrides the tool's safety check. This rewrites every ref and removes all `docs/` blobs, and it drops the `origin` remote, so re-add it locally.
- If git-filter-repo is unavailable, `git filter-branch --help` documents the slower built-in alternative.
- Verify: `du -sh .git`, `git count-objects -vH`, and `git log --all -- docs/` (should be empty).

## 5. Hand back

- Report before/after sizes, list the changed files, and give the human the exact commands to force-push the rewritten history and to tell collaborators they must re-clone (or rebase) rather than pull. Leave all pushing to the human.

## Common mistakes

- Deleting `docs/` from the working tree only and calling the repo shrunk - `.git/` is unchanged.
- Rewriting history before a verified backup.
- Force-pushing rewritten history without coordinating with collaborators.
