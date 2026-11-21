<@author>

Thanks again for sharing your work with rOpenSci. Here are my editor-checks. 

The items marked with a checkbox can help make the review process smoother; please address or justify them. The comments marked with regular bullets are optional.

Once we check all boxes we'll start searching for reviewers. And once we assign reviewers the branch under review must stay stable (i.e. the value of the `Repository:` field at the top).

<details>

> While your package is under review, please refrain from making any change, apart from hot fixes. Indeed, reviewers should be able to review the latest (best until now) version of your software, and that version should not be changing.
> -- https://devguide.ropensci.org/softwarereview_author.html#the-review-process 

</details>

When you respond to my comments, please preserve the tags and sequence, e.g. ml01, ml02 and so on. This helps track each thread.

You may use AI except for the human-to-human comments you post here. This really helps to keep the conversation human and preserves our community values. If you do use AI please tell us how so we learn from and adapt to our community ([AI policy](https://ropensci.org/blog/2026/02/26/ropensci-ai-policy/)).

Feel free to ping me for any question you may have.

### Editor checks:

- [ ] **Documentation**: The package has sufficient documentation available online (README, pkgdown docs) to allow for an assessment of functionality and scope without installing the package. In particular,
    - [ ] Is the case for the package well made?
    - [ ] Is the reference index page clear (grouped by topic if necessary)?
    - [ ] Are vignettes readable, sufficiently detailed and not just perfunctory?
- [ ] **Fit**: The package meets criteria for [fit](https://devguide.ropensci.org/policies.html#package-categories) and [overlap](https://devguide.ropensci.org/policies.html#overlap).
- [ ] **Installation instructions:** Are installation instructions clear enough for human users?
- [ ] **Tests**: If the package has some interactivity / HTTP / plot production etc. are the tests using [state-of-the-art tooling](https://devguide.ropensci.org/building.html#testing)?
- [ ] **Contributing information**: Is the documentation for contribution clear enough e.g. tokens for tests, playgrounds?
- [ ] **License:** The package has a CRAN or OSI accepted license.
- [ ] **Project management**: Are the issue and PR trackers in a good shape, e.g. are there outstanding bugs, is it clear when feature requests are meant to be tackled?
---

#### Editor comments

<!-- hide start

- [ ] ml01. Please suggest 3 reviewers. We'll use 1 at most but helps to know the expertise you're after.

<details>

> Sources of information for finding reviewers include:
> - Potential suggestions made by the submitter(s), (although submitters may have a narrow view of the types of expertise needed. We suggest not using more than one of the suggested reviewers);
> -- https://devguide.ropensci.org/softwarereview_editor.html#finding-reviewers

</details>

- mlxx. gh repo clone <Repository url> (git checkout a non-default branch?)

- mlxx. @ropensci-review-bot check package

- mlxx. Check size (LOC) in the statistical properties

- mlxx. Check recency/stability: 
    - mlxx. https://github.com/<OWNER>/<REPO>/graphs/code-frequency
    - mlxx. Ro-commits-monthly
    - mlxx. gh issue list --state all | cat
    - mlxx. gh pr list --state all | cat

- mlxx. Check size (MB): du -hd 1

- mlxx. Rscript -e “pak::pak()”

- mlxx. Rscript -e “testthat::test()”

- mlxx. Rscript -e “rcmdcheck::rcmdcheck()”

- mlxx. Rscript -e “urlchecker::url_check()”

- mlxx. Rscript -e ‘checktor::checktor()’

- mlxx. Rscript -e 'covr::package_coverage()'

- mlxx. jarl check .

- mlxx. air format .; git status -s

For stats packages also https://stats-devguide.ropensci.org/pkgsubmission.html#handling-editor-checklist

- [ ] Any issues raised during initial processing by EiC have been resolved (or there were none).
- [ ] Issues raised in the goodpractice checks, statistical anomalies, and other details of the report do not appear to be major problems and can be directed to reviewers for further scrutiny.
- [ ] Either (i) this package is aiming for a bronze badge, or, (ii) for packages aiming for silver or gold badges, the authors have clarified which of the four aspects listed in the “Guide for Authors” section on silver badges they intend to fulfil.

To copy-paste

<details>

```bash

```

</details>

hide end -->

---

