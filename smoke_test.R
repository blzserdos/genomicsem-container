################################################################################
# Smoke test, run inside the built container by the GitHub Actions workflow.
#   1. All packages load; GenomicSEM is 0.0.5 from the pinned commit.
#   2. GenomicSEM::ldsc() still contains the two top-level statements that
#      downstream code patches (the n.blocks override for > 18 traits, and the
#      final `if (stand)` return), so such patches will apply.
#   3. usermodel() fits a two-factor model to a simulated genetic covariance
#      matrix and recovers the simulated loadings.
################################################################################
suppressPackageStartupMessages({
  library(GenomicSEM)
  library(lavaan)
})
pkgs <- c("GenomicSEM", "lavaan", "psych", "GPArotation", "data.table", "Matrix", "gdata")
stopifnot(all(sapply(pkgs, requireNamespace, quietly = TRUE)))

## 1. Versions -----------------------------------------------------------------
d <- packageDescription("GenomicSEM")
stopifnot(d$Version == "0.0.5",
          identical(d$RemoteSha, "da95d431a4709693d07eae55e172ade55526948b"),
          packageVersion("lavaan") == "0.7.3")
cat("1. GenomicSEM", d$Version, "commit", substr(d$RemoteSha, 1, 7),
    "; lavaan", as.character(packageVersion("lavaan")), "\n")

## 2. ldsc() statements that downstream patches target -------------------------
b <- as.list(body(GenomicSEM::ldsc))
is_if <- function(e, cond) is.call(e) && identical(e[[1]], as.name("if")) &&
  identical(e[[2]], cond)
stopifnot(sum(vapply(b, is_if, logical(1), cond = quote(n.traits > 18))) == 1,
          is_if(b[[length(b)]], quote(stand)))
cat("2. ldsc(): block override and final return found\n")

## 3. usermodel() on simulated data --------------------------------------------
set.seed(1)
k <- 8
traits <- paste0("T", seq_len(k))
L <- cbind(c(.40, .35, .30, .30, 0, 0, 0, 0), c(0, 0, 0, 0, .30, .35, .25, .30))
S0 <- L %*% matrix(c(1, .4, .4, 1), 2) %*% t(L) + diag(.03, k)
m <- k * (k + 1) / 2
B <- 200
PV <- matrix(S0[lower.tri(S0, diag = TRUE)], B, m, byrow = TRUE) +
  0.05 * matrix(rnorm(B * m), B, m)
S <- matrix(0, k, k, dimnames = list(traits, traits))
S[lower.tri(S, diag = TRUE)] <- colMeans(PV)
S[upper.tri(S)] <- t(S)[upper.tri(S)]
fit <- suppressWarnings(usermodel(list(V = cov(PV) / B, S = S), estimation = "DWLS",
                                  model = "F1 =~ NA*T1 + T2 + T3 + T4\nF2 =~ NA*T5 + T6 + T7 + T8",
                                  std.lv = TRUE))
lam <- fit$results[fit$results$op == "=~", ]
stopifnot(max(abs(lam$Unstand_Est - L[L != 0])) < 0.02)
cat("3. usermodel(): loadings recovered (max error",
    round(max(abs(lam$Unstand_Est - L[L != 0])), 3), ")\n")

for (p in pkgs) cat(p, as.character(packageVersion(p)), "\n")
cat(R.version.string, "\nSmoke test passed\n")
