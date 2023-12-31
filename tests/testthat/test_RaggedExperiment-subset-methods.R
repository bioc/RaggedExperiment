context("RaggedExperiment-subset-methods")

test_that("[ subsetting works", {
    lgr <- list(
        A=GRanges(
            c(a="chr1:1-10", b="chr1:6-15"),
            score1 = 1:2,
            score2 = -(1:2)),
        B=GRanges(
            c(c="chr1:1-10", d="chr1:6-15"),
            score1 = 3:4,
            score2 = -(3:4)))
    colData <- DataFrame(x=1:2, id=LETTERS[1:2])
    re <- RaggedExperiment(lgr, colData=colData)

    expect_identical(re[], re)
    expect_identical(re[,], re)
    expect_identical(re[TRUE,], re)
    expect_identical(re[, TRUE], re)
    expect_identical(re[TRUE, TRUE], re)

    test <- re[1,]
    expect_identical(dim(test), c(1L, 2L))
    expect_identical(dimnames(test), list("a", c("A", "B")))
    expect_identical(assay(test), assay(re)[1,, drop=FALSE])

    test <- re[3:4,]
    expect_identical(dim(test), c(2L, 2L))
    expect_identical(dimnames(test), list(c("c", "d"), c("A", "B")))
    expect_identical(assay(test), assay(re)[3:4,, drop=FALSE])

    test <- re[2:3,]
    expect_identical(dim(test), c(2L, 2L))
    expect_identical(dimnames(test), list(c("b", "c"), c("A", "B")))
    expect_identical(assay(test), assay(re)[2:3,, drop=FALSE])

    test <- re[3:4, 2]
    expect_equal(test, RaggedExperiment(lgr[2], colData=colData[2,]))

    test <- re[4:1,][4:1,]
    expect_identical(test, re)

    test <- re[c(1, 3, 1),]
    expect_identical(dim(test), c(3L, 2L))
    expect_identical(dimnames(test), list(c("a", "c", "a"), c("A", "B")))
    expect_identical(assay(test), assay(re)[c(1, 3, 1),, drop=FALSE])

    test <- re[c(1, 3, 1),][2,]
    expect_identical(dim(test), c(1L, 2L))
    expect_identical(dimnames(test), list("c", c("A", "B")))
    expect_identical(assay(test), assay(re)[3,, drop=FALSE])

    test <- re[, 2]
    expect_identical(dim(test), c(4L, 1L))
    expect_identical(dimnames(test), list(rownames(re), "B"))
    expect_identical(assay(test), assay(re)[, 2, drop=FALSE])

    test <- re[,2:1]
    expect_identical(dim(test), c(4L, 2L))
    expect_identical(dimnames(test), list(rownames(re), colnames(re)[2:1]))
    expect_identical(assay(test), assay(re)[, 2:1, drop=FALSE])

    test <- re[, 2:1][, 2:1]
    expect_identical(test, re)

    test <- re[4:1, 2:1][4:1, 2:1]
    expect_identical(test, re)

    ## auto-dimnames
    lgr <- list(
        GRanges(c("chr1:1-10", "chr1:6-15"), score1 = 1:2),
        GRanges(c("chr1:1-10", "chr1:6-15"), score1 = 3:4)
    )
    rownames <- paste0("chr1:", c(1, 6, 1, 6), "-", c(10, 15, 10, 15))
    re <- RaggedExperiment(lgr)
    expect_identical(
        assay(re),
        matrix(
            c(1:2, NA, NA, NA, NA, 3:4), ncol = 2,
            dimnames=list(rownames, NULL)
        )
    )

    ridx <- c(1, 4, 2, 3)
    expect_identical(
        assay(re[ridx,]),
        matrix(
            c(1L, NA, 2L, NA, NA, 4L, NA, 3L), ncol = 2,
            dimnames=list(rownames[ridx], NULL)
        )
    )
})

test_that("subsetByOverlaps works", {
    sample1 <- GRanges(
        c(A = "chr1:1-10:-", B = "chr1:8-14:+", C = "chr2:15-18:+"),
        score = 3:5)
    sample2 <- GRanges(
        c(D = "chr1:1-10:-", E = "chr2:11-18:+"),
        score = 1:2)
    colDat <- DataFrame(id = 1:2)
    re <- RaggedExperiment(
        sample1 = sample1,
        sample2 = sample2,
        colData = colDat)
    range <- GRanges("chr1:3-10")
    expect_identical(
        subsetByOverlaps(rowRanges(re), range),
        rowRanges(subsetByOverlaps(re, range))
    )
})

test_that("subset works", {
    sample1 <- GRanges(
        c(A = "chr1:1-10:-", B = "chr1:8-14:+", C = "chr2:15-18:+"),
        score = 3:5)
    sample2 <- GRanges(
        c(D = "chr1:1-10:-", E = "chr2:11-18:+"),
        score = 1:2)
    colDat <- DataFrame(id = 1:2)
    re <- RaggedExperiment(
        sample1 = sample1,
        sample2 = sample2,
        colData = colDat)
    res <- subset(re, subset = score >= 3L)
    expect_identical(mcols(res), DataFrame(score = 3:5))
    expect_identical(dim(res), c(3L, 2L))
    res <- subset(re, select = id == 1)
    expect_identical(colData(res), DataFrame(id = 1L, row.names = "sample1"))
    expect_identical(dim(res), c(5L, 1L))
})
