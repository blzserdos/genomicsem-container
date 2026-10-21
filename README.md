# genomicsem-container

Apptainer/Singularity `.sif` container with **R 4.5.3** and
[GenomicSEM](https://github.com/GenomicSEM/GenomicSEM) **0.0.5**, pinned to
commit
[`123ec96`](https://github.com/GenomicSEM/GenomicSEM/commit/123ec96517b67330d7b7933b9f3834a9cf55cde0)
(3 April 2026), for running Genomic SEM on HPC systems without internet
access, such as TSD.

| Package | Version source |
|---|---|
| `GenomicSEM` | GitHub, pinned commit |
| `lavaan` | CRAN, pinned to 0.6-21 |
| `psych`, `GPArotation`, `data.table`, `Matrix`, `gdata` | CRAN, Posit Package Manager snapshot of 2026-10-15 |

All dependencies are included. GenomicSEM is pinned to a commit, not a branch,
because code that patches or reproduces GenomicSEM internals (for example
`ldsc()` or `usermodel()`) is only valid for the version it was checked
against.

**lavaan is pinned to 0.6-21** because GenomicSEM 0.0.5 (this commit) fails
with lavaan 0.7.x: `usermodel()` stops with `object 'ReorderModel' not found`
(its first `sem()` call errors inside a `tryCatch`). Found by this repo's first
build, 2026-10-21.

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
