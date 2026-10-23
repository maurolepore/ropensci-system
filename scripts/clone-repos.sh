#!/usr/bin/env bash
# Re-materialize the reference clones for this knowledge base.
# The KB repo itself tracks only curated content (index.md, concepts/, docs/, ...);
# these clones are gitignored reference material (see root AGENTS.md).
#
# Usage:  scripts/clone-repos.sh        # from the KB root
# Safe to re-run: existing clones are skipped.
set -euo pipefail
cd "$(dirname "$0")/.."

clone() { # clone <path> <remote-url>
  if [ -d "$1/.git" ]; then
    echo "skip  $1 (already cloned)"
  else
    echo "clone $1"
    git clone --quiet "$2" "$1"
  fi
}

# ropensci — dev_guide and roweb3 are maurolepore forks; canonical upstreams are
# github.com/ropensci/dev_guide and github.com/ropensci/roweb3.
clone ropensci/dev_guide                            git@github.com:maurolepore/dev_guide.git
clone ropensci/roweb3                               git@github.com:maurolepore/roweb3.git
clone ropensci/software-review                      git@github.com:ropensci/software-review.git
clone ropensci/statistical-software-review-book     https://github.com/ropensci/statistical-software-review-book.git

# ropensci-org
clone ropensci-org/badges                           git@github.com:ropensci-org/badges.git
clone ropensci-org/buffy                            git@github.com:ropensci-org/buffy.git
clone ropensci-org/pkgreviewr                       git@github.com:ropensci-org/pkgreviewr.git

# ropensci-review-tools
clone ropensci-review-tools/autotest                git@github.com:ropensci-review-tools/autotest.git
clone ropensci-review-tools/dashboard               git@github.com:ropensci-review-tools/dashboard.git
clone ropensci-review-tools/designlens              git@github.com:ropensci-review-tools/designlens.git
clone ropensci-review-tools/pkgcheck                git@github.com:ropensci-review-tools/pkgcheck.git
clone ropensci-review-tools/pkgcheck-action         git@github.com:ropensci-review-tools/pkgcheck-action.git
clone ropensci-review-tools/pkgstats                git@github.com:ropensci-review-tools/pkgstats.git
clone ropensci-review-tools/ropensci-review-tools   git@github.com:ropensci-review-tools/ropensci-review-tools.git
clone ropensci-review-tools/roreviewapi             git@github.com:ropensci-review-tools/roreviewapi.git
clone ropensci-review-tools/srr                     git@github.com:ropensci-review-tools/srr.git

# ropensci-training — software-review-private is a maurolepore fork.
clone ropensci-training/saperlipopette              https://github.com/ropensci-training/saperlipopette
clone ropensci-training/software-review             git@github.com:ropensci-training/software-review.git
clone ropensci-training/software-review-private     git@github.com:maurolepore/software-review-private.git

echo "Done. Note: ropensci/lyh970817 is not a git repo and is not re-created by this script."
