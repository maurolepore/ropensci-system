---
type: Plan
status: draft
generated:
  by: "process:opencode (kimi-k3)"
  at: 2026-10-24T12:38:55Z
---

# Buffy Development Environment — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `bundle install` succeed and `bundle exec rspec` run green for ropensci-org/buffy on branch `ropensci` (79e65b3) on this macOS arm64 machine.

**Architecture:** Ruby 4.0.2 comes from either a Docker container (fastest, zero installs; daemon already running) or a native mise install (daily-driver). Native gems (charlock_holmes, openssl, rugged, nokogiri, puma) are satisfied with two brew packages plus `PKG_CONFIG_PATH` pointing at keg-only icu4c/openssl@3. The test suite is fully self-contained — no Redis, no GitHub token, no cloc — because `spec/spec_helper.rb` sets `RACK_ENV=test` (loads `config/settings-test.yml` with dummy values), `WebMock.disable_net_connect!`, and `Sidekiq.testing!(:fake)`, and CI runs with no services.

**Tech Stack:** Ruby 4.0.2, Bundler 4.0.6, Sinatra 4.2.1, Sidekiq 8.1.3, RSpec 3.13, Puma 8; Docker 29.6.1 or mise + Homebrew 7.0.10 on macOS 15.7.7 arm64.

**Spec:** User request, 2026-10-24 (this session): produce a plan only — no installs or changes yet. Verify (don't assume) the pinned Ruby/bundler, inspect Gemfile/CI/spec_helper for real requirements, flag each step [system-wide] vs [repo-local], give every step a verification command, end with the single fastest path to green `bundle exec rspec`. Repo context: [buffy concept doc](../../../concepts/buffy.md).

## Global Constraints

Every task implicitly includes these verified facts:

- Ruby **exactly 4.0.2** — `.ruby-version` = `4.0.2`; `Gemfile.lock` has `RUBY VERSION ruby 4.0.2` (bundler rejects other patch levels). The Gemfile itself has no `ruby` directive unless `CUSTOM_RUBY_VERSION` is set (Heroku deploy knob).
- Bundler **exactly 4.0.6** — `Gemfile.lock` tail: `BUNDLED WITH 4.0.6`.
- Work on branch `ropensci` (local `ropensci` == `origin/ropensci` == 79e65b3). `main` is upstream JOSS. The only authorized git mutation is switching to `ropensci`.
- `.bundle/config` is a **tracked file** (`BUNDLE_FROZEN: "false"`) — do NOT let bundler write local build config into it (`bundle config set --local`); pass build flags via environment (`PKG_CONFIG_PATH`) instead.
- Tests need **no external services**: `.github/workflows/tests.yml` (matrix ruby 3.3/3.4/4.0, `ruby/setup-ruby`, no services block) runs `bundle exec rspec spec`; `spec/spec_helper.rb` sets `ENV['RACK_ENV']='test'` → `app/buffy.rb:11` loads `config/settings-test.yml` (dummy tokens), `WebMock.disable_net_connect!(allow_localhost: true)`, `Sidekiq.testing!(:fake)`; cloc is stubbed (`spec/utilities_spec.rb` stubs `Open3.capture3("cloc", ...)`); zero `redis` references under `spec/`.
- Machine (verified 2026-10-24): macOS 15.7.7 arm64; system Ruby 2.6.10 (never use it); Homebrew 7.0.10; Docker CLI **and** daemon 29.6.1 running; Xcode CLT present; **no** rbenv/rvm/asdf/mise/chruby. Brew already installed: openssl@3 3.6.4, icu4c@78 78.3, libyaml, readline, gmp. Missing: cmake, pkg-config.
- Working tree currently sits on branch `142_set-hold-reminder` with a **modified `.gitignore`**.
- Secrets: env var NAMES only in this plan; never record token values.

## Review Focus

Risks the spec implies but no step's happy-path test fully covers:

1. `charlock_holmes 0.7.9` vs `icu4c@78` — unverified compile pairing; ICU ≥ 75 C++ API churn has broken native gems before. Mitigation: Task 3 step 3 smoke-test; fallback = Path A (Docker) or an older keg-only icu4c.
2. `openssl 3.3.2` gem cannot find keg-only `openssl@3` by itself → Task 3 step 1 exports `PKG_CONFIG_PATH`; step 3 requires the lib to prove it.
3. Docker tag `ruby:4.0.2` may not exist or `ruby:4.0` may be a newer patch that bundler rejects → Task 2A step 1 verifies exact `ruby -v` output; never edit the lockfile to relax the pin.
4. Dirty `.gitignore` on `142_set-hold-reminder` would be carried into (or block) the checkout → Task 1 stashes first.
5. A fresh Ruby 4.0.2 may ship a bundler ≠ 4.0.6 → explicit `gem install bundler -v 4.0.6` before `bundle install` in both paths.

---

### Task 1: Check out the `ropensci` branch

**Files:** none (git state only). Authorized by the user's instruction "work on the `ropensci` branch".

- [ ] **Step 1: Stash the dirty `.gitignore`** [repo-local]

```bash
git diff .gitignore   # review first; if it is junk use: git checkout -- .gitignore
git stash push -m "wip: gitignore on 142_set-hold-reminder"
```

Verify: `git status -s` → empty.

- [ ] **Step 2: Switch branch** [repo-local]

```bash
git checkout ropensci
```

Verify: `git branch --show-current` → `ropensci`; `git rev-parse --short HEAD` → `79e65b3`.

### Task 2: Install Ruby 4.0.2 — pick exactly ONE path

**Ground truth:** `.ruby-version`, `Gemfile.lock`, and CI all pin 4.0.2; CI uses `ruby/setup-ruby@v1`.

| Option | System footprint | Time to green | Verdict |
| --- | --- | --- | --- |
| **Docker** (Path A) | nothing installed; image + named volume only | ~5 min (image pull + gem compile) | **Fastest** — daemon already running |
| **mise** (Path B) | 3 brew formulae + one `~/.zshrc` line | ~15–25 min (source compile) | **Best native daily driver** — one tool, reads `.ruby-version` |
| rbenv + ruby-build | 2 brew formulae + shims + `~/.zshrc` line | ~15–25 min | equal result, more pieces; only if already installed (it is not) |
| asdf | brew formula + plugin + `.tool-versions` (repo lacks one) | ~15–25 min | most moving parts; rejected |

#### Path A — Docker (recommended for the fastest green suite)

- [ ] **A1: Pull the exact image** [system-wide: docker state]

```bash
docker pull ruby:4.0.2
```

Verify: `docker run --rm ruby:4.0.2 ruby -v` → `ruby 4.0.2 ...`. If the tag is missing, `docker pull ruby:4.0` and re-verify the patch level is exactly 4.0.2 (Review Focus #3).

- [ ] **A2: Persist the gem home in a named volume** [system-wide: docker state]

```bash
docker volume create buffy-bundle
```

Verify: `docker volume inspect buffy-bundle > /dev/null && echo ok`.

- [ ] **A3: Open a dev container on the repo** [container-local]

```bash
docker run --rm -it -v "$PWD":/app -w /app -v buffy-bundle:/usr/local/bundle ruby:4.0.2 bash
```

(`/usr/local/bundle` is the ruby image's GEM_HOME; mounting the volume there keeps gems out of the repo and survives container exits.) Verify inside: `ruby -v` → `ruby 4.0.2`.

- [ ] **A4: Native-build dependencies inside the container** [container-local]

```bash
apt-get update && apt-get install -y --no-install-recommends libicu-dev cmake pkg-config libssl-dev
```

(charlock_holmes ← libicu-dev; rugged's vendored libgit2 ← cmake + pkg-config; openssl gem ← libssl-dev; nokogiri compiles via mini_portile2 with the image's toolchain.) Verify: `pkg-config --modversion icu-i18n openssl` prints two version numbers.

- [ ] **A5: Bundler + install** [container-local]

```bash
gem install bundler -v 4.0.6
bundle install
```

Verify: `bundle -v` → `Bundler version 4.0.6`; `bundle check` → `The Gemfile's dependencies are satisfied`. Then go to Task 4 (inside the container).

#### Path B — native via mise (recommended for ongoing development)

- [ ] **B1: Install mise and the two missing build tools** [system-wide]

```bash
brew install mise cmake pkg-config
```

(openssl@3, icu4c@78, readline, libyaml, gmp already installed — re-check with `brew list --versions openssl@3 icu4c@78 readline libyaml gmp`.) Verify: `mise --version`; `cmake --version`; `pkg-config --version`.

- [ ] **B2: Activate mise in the shell** [system-wide: user dotfile]

```bash
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
eval "$(mise activate zsh)"
```

Verify: `mise doctor` → no problems.

- [ ] **B3: Install Ruby 4.0.2 (source compile, ~10–20 min on arm64)** [user-level: ~/.local/share/mise]

```bash
mise use -g ruby@4.0.2
```

(`-g` writes the global default to `~/.config/mise/config.toml`, adding nothing to the repo; the repo's `.ruby-version` independently requests 4.0.2.) Verify: `cd` into the clone, `ruby -v` → `ruby 4.0.2`.

- [ ] **B4: Bundler 4.0.6** [user-level gems]

```bash
gem install bundler -v 4.0.6
```

Verify: `bundle -v` → `Bundler version 4.0.6`.

### Task 3: `bundle install` (Path B only — Path A already installed in A5)

**Consumes:** Task 2B's ruby/bundler on PATH. **Produces:** a satisfied Gemfile, proven by native-extension smoke test.

- [ ] **Step 1: Expose keg-only libraries to native builds** [repo-local: env only, nothing written]

```bash
export PKG_CONFIG_PATH="$(brew --prefix icu4c@78)/lib/pkgconfig:$(brew --prefix openssl@3)/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
```

One env var covers both charlock_holmes (icu-i18n) and the openssl gem. Verify: `pkg-config --modversion icu-i18n openssl` prints two versions.

- [ ] **Step 2: Install the bundle** [repo-local]

```bash
bundle install
```

Verify: `bundle check` → `The Gemfile's dependencies are satisfied`; `git status -s` shows no change to `.bundle/config` or `Gemfile.lock`.

- [ ] **Step 3: Smoke-test every native extension** [repo-local]

```bash
bundle exec ruby -e 'require "openssl"; require "charlock_holmes"; require "rugged"; require "nokogiri"; require "puma"; puts "native exts OK"'
```

Expected: `native exts OK`. If charlock_holmes fails to build/load (Review Focus #1): switch to Path A, or try an older keg-only icu4c (`brew search icu4c`) and point step 1 at it.

### Task 4: Green `bundle exec rspec`

- [ ] **Step 1: Run the suite** [repo-local]

```bash
bundle exec rspec
```

(Same as CI's `bundle exec rspec spec`; `.rspec` adds `--format d --color`.) Verify: final summary line shows `0 failures`. No Redis, GitHub token, or cloc needed — see Global Constraints.

### Task 5 (OPTIONAL — only to run the app locally; NOT needed for tests)

Ground truth: `docs/installation.md`, `Procfile`, `puma-config.rb`, `config/settings-development.yml`.

- [ ] **Step 1: Redis** — either [system-wide] `brew install redis && brew services start redis`, or [system-wide: docker] `docker run -d --name buffy-redis -p 6379:6379 redis:7`. Verify: `redis-cli ping` → `PONG` (or `docker exec buffy-redis redis-cli ping`).
- [ ] **Step 2: cloc** (only the repo-checks worker shells out to it at runtime) [system-wide] `brew install cloc`. Verify: `cloc --version`.
- [ ] **Step 3: Env vars** [repo-local: shell env] `BUFFY_BOT_GH_USER`, `BUFFY_GH_ACCESS_TOKEN` (token scopes per installation.md: `public_repo`, `repo:invite`, `read:org`, `read:user`, plus `admin:org` if using the approval responder), `BUFFY_GH_SECRET_TOKEN`, `RACK_ENV=development` (so `app/buffy.rb` loads `config/settings-development.yml`). Never write values into the repo or KB.
- [ ] **Step 4: Web process** [repo-local] `bundle exec puma -C ./puma-config.rb`. Verify: `curl localhost:3000/status` → `... up and running!`
- [ ] **Step 5: Worker process** (second terminal) [repo-local] `bundle exec sidekiq -t 45 -r ./app/lib/workers.rb`. Verify: Sidekiq boot banner, connected to Redis, no crash.

### Task 6 (OPTIONAL — build the Sphinx docs in `docs/`)

Ground truth: `docs/requirements.txt` (docutils, recommonmark, sphinx_rtd_theme — sphinx arrives transitively), `docs/Makefile`, `.readthedocs.yaml` (python 3.12).

- [ ] **Step 1: Check Python** `python3 --version`. RTD builds with 3.12; if the system python3 is much older, [system-wide] `brew install python@3.12`.
- [ ] **Step 2: Isolated env + deps** [repo-local]

```bash
python3 -m venv docs/.venv
docs/.venv/bin/pip install -r docs/requirements.txt
```

Verify: `docs/.venv/bin/sphinx-build --version` prints a version. (Requirements are unpinned — if resolution breaks, that is a pre-existing repo issue, not this plan's scope.)

- [ ] **Step 3: Build** [repo-local] `docs/.venv/bin/sphinx-build -b html docs docs/_build/html` (or `cd docs && make html` with the venv activated). Verify: `test -f docs/_build/html/index.html && echo built`.

## Fastest path to a green `bundle exec rspec`

From the clone root (≈5 minutes, nothing installed on the host):

```bash
git stash push -m wip && git checkout ropensci
docker pull ruby:4.0.2 && docker volume create buffy-bundle
docker run --rm -it -v "$PWD":/app -w /app -v buffy-bundle:/usr/local/bundle ruby:4.0.2 bash -c '
  apt-get update -qq &&
  apt-get install -y -qq --no-install-recommends libicu-dev cmake pkg-config libssl-dev &&
  gem install bundler -v 4.0.6 &&
  bundle install &&
  bundle exec rspec'
```

Expected tail: `... 0 failures`.
