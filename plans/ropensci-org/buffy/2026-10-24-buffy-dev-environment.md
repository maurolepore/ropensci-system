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

**Architecture:** Ruby 4.0.2 is delivered twice by design — Path A (Docker container: fastest, zero installs; daemon already running) runs first for an immediate green suite, then Path B (native mise install) becomes the standing daily-driver, with Path A staying available as a permanent fallback. (User decision, 2026-10-24: run BOTH paths.) Native gems (charlock_holmes, openssl, rugged, nokogiri, puma) are satisfied with two brew packages plus `PKG_CONFIG_PATH` pointing at keg-only icu4c/openssl@3. The test suite is fully self-contained — no Redis, no GitHub token, no cloc — because `spec/spec_helper.rb` sets `RACK_ENV=test` (loads `config/settings-test.yml` with dummy values), `WebMock.disable_net_connect!`, and `Sidekiq.testing!(:fake)`, and CI runs with no services.

**Tech Stack:** Ruby 4.0.2, Bundler 4.0.6, Sinatra 4.2.1, Sidekiq 8.1.3, RSpec 3.13, Puma 8; Docker 29.6.1 or mise + Homebrew 7.0.10 on macOS 15.7.7 arm64.

**Spec:** User request, 2026-10-24 (this session): produce a plan only — no installs or changes yet. Verify (don't assume) the pinned Ruby/bundler, inspect Gemfile/CI/spec_helper for real requirements, flag each step [system-wide] vs [repo-local], give every step a verification command, end with the single fastest path to green `bundle exec rspec`. Repo context: [buffy concept doc](../../../concepts/buffy.md).

## Global Constraints

Every task implicitly includes these verified facts:

- Ruby **4.0.2** is the development/deployment target — `.ruby-version` = `4.0.2`; `Gemfile.lock` records `RUBY VERSION ruby 4.0.2`. This is NOT a hard bundler gate: the Gemfile has no active `ruby` directive (only `if ENV["CUSTOM_RUBY_VERSION"]`), so bundler does not reject a different running Ruby — the repo's own CI runs this same Gemfile.lock green under ruby 3.3 and 3.4 (verified check runs on 79e65b3). Target 4.0.2 anyway for parity with `.ruby-version` and CI's 4.0 leg.
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
3. Docker tag `ruby:4.0.2` may not exist (unverifiable while planning without pulling an image) → Task 2A step 1 verifies `ruby -v`. A slightly newer 4.0.x patch level is acceptable to bundler here (no active `ruby` directive; CI green on 3.3/3.4 with this lockfile), so if `ruby:4.0.2` is missing, `ruby:4.0` still yields a green suite. Never edit `Gemfile.lock` to relax the pin regardless.
4. Dirty `.gitignore` on `142_set-hold-reminder` would be carried into (or block) the checkout → Task 1 stashes first.
5. A fresh Ruby 4.0.2 may ship a bundler ≠ 4.0.6 → explicit `gem install bundler -v 4.0.6` before `bundle install` in both paths.

---

### Task 1: Check out the `ropensci` branch

**Files:** none (git state only). Authorized by the user's instruction "work on the `ropensci` branch".

- [ ] **Step 1: Stash the dirty `.gitignore`** [repo-local]

```bash
git stash push -m "wip: .gitignore on 142_set-hold-reminder"
git stash show -p 'stash@{0}'   # review what was parked; restore later with git stash pop
```

(Discarding the parked change — `git stash drop` or `git checkout -- .gitignore` — is a last resort for junk-only changes, never the default.) Verify: `git status -s` → empty.

- [ ] **Step 2: Switch branch** [repo-local]

```bash
git checkout ropensci
```

Verify: `git branch --show-current` → `ropensci`; `git rev-parse --short HEAD` → `79e65b3`.

### Task 2: Install Ruby 4.0.2 — BOTH paths: A first (fast green suite), then B (standing setup)

**Ground truth:** `.ruby-version`, `Gemfile.lock`, and CI all pin 4.0.2; CI uses `ruby/setup-ruby@v1`.

| Option | System footprint | Time to green | Verdict |
| --- | --- | --- | --- |
| **Docker** (Path A) | nothing installed; image + named volume only | ~5 min (image pull + gem compile) | **Do first** — immediate green suite; stays as permanent fallback |
| **mise** (Path B) | 3 brew formulae + one `~/.zshrc` line | ~15–25 min (source compile) | **Do second** — standing daily driver; one tool, reads `.ruby-version` |
| rbenv + ruby-build | 2 brew formulae + shims + `~/.zshrc` line | ~15–25 min | equal result, more pieces; only if already installed (it is not) |
| asdf | brew formula + plugin + `.tool-versions` (repo lacks one) | ~15–25 min | most moving parts; rejected |

Both paths coexist cleanly — execute them in order:

- mise owns the **host shell** (it reads the repo's `.ruby-version`); Docker never touches the host Ruby.
- Gems live in **separate stores** (mise's gem home vs the `buffy-bundle` docker volume), so `bundle install`
  runs once per path and the two don't interfere.
- Once Path B is green, Path A remains the fallback for Review Focus #1/#2 (native-gem compile issues) and for
  quick disposable checks.

#### Path A — Docker (do first — immediate green suite)

- [ ] **A1: Pull the exact image** [system-wide: docker state]

```bash
docker pull ruby:4.0.2
```

Verify: `docker run --rm ruby:4.0.2 ruby -v` → `ruby 4.0.2 ...`. If the tag is missing, `docker pull ruby:4.0` — per Review Focus #3, a slightly newer 4.0.x patch level still yields a green suite (verify whatever `ruby -v` prints).

- [ ] **A2: Persist the gem home in a named volume** [system-wide: docker state]

```bash
docker volume create buffy-bundle
```

Verify: `docker volume inspect buffy-bundle > /dev/null && echo ok`.

- [ ] **A3: Open a dev container on the repo** [container-local]

```bash
docker run --rm -it -v "$PWD":/app -w /app -v buffy-bundle:/usr/local/bundle ruby:4.0.2 bash
```

(`/usr/local/bundle` is the ruby image's GEM_HOME; mounting the volume there keeps gems out of the repo and survives container exits.) Verify inside: `ruby -v` → `ruby 4.0.2`. The container is disposable (`--rm`): exiting mid-flow or after a green run means re-running A3→A5 costs only the ~1 min apt step; the bundle persists in the volume.

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

Verify: `bundle -v` → `Bundler version 4.0.6`; `bundle check` → `The Gemfile's dependencies are satisfied`. Then go to Task 4 (inside the container). Once green, continue with Path B below — the container may be disposed; its bundle survives in the volume.

#### Path B — native via mise (do second — the standing daily-driver setup)

- [ ] **B1: Install mise and the two missing build tools** [system-wide]

```bash
brew install mise cmake pkg-config
```

(openssl@3, icu4c@78, readline, libyaml, gmp already installed — re-check with `brew list --versions openssl@3 icu4c@78 readline libyaml gmp`.) Verify: `mise --version`; `cmake --version`; `pkg-config --version`. Note: mise's Ruby installer may itself `brew install` extra build deps (e.g. autoconf) on first use — the footprint can grow by a few formulae.

- [ ] **B2: Activate mise in the shell** [system-wide: user dotfile]

```bash
grep -qF 'mise activate' ~/.zshrc || echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
eval "$(mise activate zsh)"
```

Verify: `command -v ruby` → `/Users/<you>/.local/share/mise/shims/ruby`. (`mise doctor` may report benign warnings and exit non-zero on healthy setups — only missing shims are a real problem.)

- [ ] **B3: Install Ruby 4.0.2 (source compile, ~10–20 min on arm64)** [user-level: ~/.local/share/mise]

```bash
mise use -g ruby@4.0.2
```

(`-g` writes the global default to `~/.config/mise/config.toml`, adding nothing to the repo; the repo's `.ruby-version` independently requests 4.0.2.) Verify: `cd` into the clone, `ruby -v` → `ruby 4.0.2`.

- [ ] **B4: Bundler 4.0.6** [user-level gems]

```bash
gem install bundler -v 4.0.6
```

Verify: `bundle -v` → `Bundler version 4.0.6`. → continue directly to Task 3 (host `bundle install`).

### Task 3: `bundle install` on the host (after Path B — Path A's copy lives inside the container (A5))

**Consumes:** Task 2B's ruby/bundler on PATH. **Produces:** a satisfied Gemfile, proven by native-extension smoke test.

- [ ] **Step 1: Expose keg-only libraries to native builds** [repo-local: env only, nothing written]

```bash
export PKG_CONFIG_PATH="$(brew --prefix icu4c@78)/lib/pkgconfig:$(brew --prefix openssl@3)/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export CPATH="$(brew --prefix openssl@3)/include:$(brew --prefix icu4c@78)/include:${CPATH:-}"
export LIBRARY_PATH="$(brew --prefix openssl@3)/lib:$(brew --prefix icu4c@78)/lib:${LIBRARY_PATH:-}"
```

PKG_CONFIG_PATH covers charlock_holmes (icu-i18n); CPATH/LIBRARY_PATH are belt-and-braces for the openssl gem, whose extconf may not consume pkg-config for a keg-only prefix (UNVERIFIED — no build was made while planning). If the openssl gem still fails to compile, install it directly before `bundle install`:

```bash
gem install openssl -v 3.3.2 -- --with-openssl-dir="$(brew --prefix openssl@3)"
```

Verify: `pkg-config --modversion icu-i18n openssl` prints two versions.

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
cd /Users/maurolepore/git/ropensci-system/ropensci-org/buffy   # the clone; $PWD below must be this dir
git diff .gitignore && git stash push -m wip && git checkout ropensci
docker pull ruby:4.0.2 && docker volume create buffy-bundle
docker run --rm -it -v "$PWD":/app -w /app -v buffy-bundle:/usr/local/bundle ruby:4.0.2 bash -c '
  apt-get update -qq &&
  apt-get install -y -qq --no-install-recommends libicu-dev cmake pkg-config libssl-dev &&
  gem install bundler -v 4.0.6 &&
  bundle install &&
  bundle exec rspec'
```

Expected tail: `... 0 failures`.
