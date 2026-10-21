# genomicsem-container

Apptainer/Singularity `.sif` container with **R 4.5.3** and
[GenomicSEM](https://github.com/GenomicSEM/GenomicSEM) **0.0.5**, pinned to
commit
[`da95d43`](https://github.com/GenomicSEM/GenomicSEM/commit/da95d431a4709693d07eae55e172ade55526948b)
(28 September 2026), for running Genomic SEM on HPC systems without internet
access, such as TSD.

| Package | Version source |
|---|---|
| `GenomicSEM` | GitHub, pinned commit |
| `lavaan` | CRAN, pinned to 0.7-3 |
| `psych`, `GPArotation`, `data.table`, `Matrix`, `gdata` | CRAN, Posit Package Manager snapshot of 2026-10-15 |

All dependencies are included. GenomicSEM is pinned to a commit, not a branch,
because code that patches or reproduces GenomicSEM internals (for example
`ldsc()` or `usermodel()`) is only valid for the version it was checked
against.

**GenomicSEM and lavaan 0.7.** lavaan 0.7 refuses `estimator = "DWLS"` on
continuous data unless `ordered = FALSE` is set. GenomicSEM added that argument
in commit `bba1042` (2026-09-28). Older commits fail with lavaan 0.7.x:
`usermodel()` stops with `object 'ReorderModel' not found`. Image 1.0.0 (release
`build-a867e8b`) has the older pair, GenomicSEM `123ec96` with lavaan 0.6-21.
On a 13-disorder Genomic SEM model the two images agree to within about 10⁻⁶.

---

## How it works

Every push to `main` that touches `genomicsem.def`, `smoke_test.R` or the
workflow triggers a GitHub Actions build. The runner installs Apptainer, builds
the image, runs `smoke_test.R` inside it, and uploads `genomicsem.sif` as a
**GitHub Release** asset. A build can also be started by hand from
**Actions → Build GenomicSEM Apptainer container → Run workflow**.

The smoke test checks that:
1. all packages load, and GenomicSEM is 0.0.5 from the pinned commit;
2. `ldsc()` still has the statements that downstream patches target;
3. `usermodel()` recovers the loadings of a simulated two-factor model.

---

## Downloading the container

From the **Releases** tab, take the latest release and download
`genomicsem.sif`, or with the GitHub CLI:

```bash
gh release download --repo blzserdos/genomicsem-container --pattern "genomicsem.sif"
```

On TSD, bring the `.sif` in through the usual data import.

---

## Using the container

```bash
# Run an R script (bind the directories your scripts and data live in)
apptainer run --bind /path/to/project genomicsem.sif my_analysis.R

# One-liner
apptainer exec genomicsem.sif Rscript -e "library(GenomicSEM); sessionInfo()"

# Interactive R, or a shell inside the container
apptainer exec genomicsem.sif R
apptainer shell genomicsem.sif
```

---

## Licence

The files in this repository are MIT-licensed (see `LICENSE`). The image
contains R, GenomicSEM (GPL-3) and other open-source packages under their own
licences; their sources are available from CRAN and GitHub.
