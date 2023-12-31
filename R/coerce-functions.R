#' @rdname coerce-functions
#'
#' @title Create SummarizedExperiment representations by transforming
#'     ragged assays to rectangular form.
#'
#' @description These methods transform \code{RaggedExperiment}
#'     objects to similar \code{SummarizedExperiment} objects. They do
#'     so by transforming assay data to more rectangular
#'     representations, following the rules outlined for similarly
#'     names transformations \code{sparseAssay()},
#'     \code{compactAssay()}, \code{disjoinAssay()}, and
#'     \code{qreduceAssay()}. Because of the complexity of the
#'     transformation, ti usually only makes sense transform
#'     \code{RaggedExperiment} objects with a single assay; this is
#'     currently enforced at time of coercion.
#'
#' @param x \code{RaggedExperiment}
#'
#' @param i \code{integer(1)}, \code{character(1)}, or
#'     \code{logical()} selecting the assay to be transformed.
#'
#' @param simplifyDisjoin \code{function} of 1 argument, used to
#'     transform assays. See \code{\link{assay-functions}}.
#'
#' @param simplifyReduce \code{function} of 3 arguments used to transform
#'     assays. See \code{\link{assay-functions}}.
#'
#' @param query \code{GRanges} provding regions over which reduction
#'     is to occur.
#'
#' @param withDimnames \code{logical(1)} default TRUE. propagate
#'     dimnames to SummarizedExperiment.
#'
#' @param sparse logical(1) whether to return a
#'     \code{\link[Matrix]{sparseMatrix}} representation
#'
#' @return All functions return \code{RangedSummarizedExperiment}.
#'
#' @return \code{sparseSummarizedExperiment} has \code{rowRanges()}
#'     identical to the row ranges of \code{x}, and \code{assay()}
#'     data as \code{sparseAssay()}. This is very space-inefficient
#'     representation of ragged data. Use 'sparse=TRUE' to obtain
#'     a \code{\link[Matrix]{sparseMatrix}} assay representation.
#'
#' @example inst/scripts/coerce-functions-Ex.R
#'
#' @importFrom SummarizedExperiment SummarizedExperiment rowData
#'
#' @export
sparseSummarizedExperiment <-
    function(x, i = 1, withDimnames=TRUE, sparse = FALSE)
{
    i <- .assay_i(x, i)
    name <- assayNames(x)[[i]]
    assay <- sparseAssay(x, i, withDimnames=withDimnames, sparse = sparse)
    assay <- setNames(list(assay), name)

    colData <- colData(x)
    rowRanges <- rowRanges(x)
    if (!withDimnames) {
        names(rowRanges) <- rownames(colData) <- NULL
    }

    SummarizedExperiment(assay, rowRanges=rowRanges, colData=colData)
}

#' @rdname coerce-functions
#'
#' @return \code{compactSummarizedExperiment} has \code{rowRanges()}
#'     identical to the row ranges of \code{x}, and \code{assay()}
#'     data as \code{compactAssay()}. This is space-inefficient
#'     representation of ragged data when samples are primarily
#'     composed of different ranges. Use 'sparse=TRUE' to obtain
#'     a \code{\link[Matrix]{sparseMatrix}} assay representation.
#'
#' @importFrom GenomicRanges GRanges
#'
#' @export
compactSummarizedExperiment <-
    function(x, i = 1L, withDimnames=TRUE, sparse = FALSE)
{
    i <- .assay_i(x, i)
    name <- assayNames(x)[[i]]
    assay <- compactAssay(x, i, sparse = sparse)
    rowRanges <- setNames(GRanges(rownames(assay)), rownames(assay))
    if (!withDimnames)
        assay <- unname(assay)
    assay <- setNames(list(assay), name)

    colData <- colData(x)
    if (!withDimnames) {
        names(rowRanges) <- rownames(colData) <- NULL
    }

    SummarizedExperiment(assay, rowRanges=rowRanges, colData=colData)
}

#' @rdname coerce-functions
#'
#' @return \code{disjoinSummarizedExperiment} has \code{rowRanges()}
#'     identical to the disjoint row ranges of \code{x},
#'     \code{disjoint(rowRanges(x))}, and \code{assay()} data as
#'     \code{disjoinAssay()}.
#'
#' @export
disjoinSummarizedExperiment <-
    function(x, simplifyDisjoin, i = 1L, withDimnames=TRUE)
{
    stopifnot_simplify_ok(simplifyDisjoin, 1L)

    i <- .assay_i(x, i)
    name <- assayNames(x)[[i]]
    assay <- disjoinAssay(x, simplifyDisjoin, i)
    rowRanges <- setNames(GRanges(rownames(assay)), rownames(assay))
    if (!withDimnames)
        assay <- unname(assay)
    assay <- setNames(list(assay), name)

    colData <- colData(x)
    if (!withDimnames) {
        names(rowRanges) <- rownames(colData) <- NULL
    }

    SummarizedExperiment(assay, rowRanges=rowRanges, colData=colData)
}

#' @rdname coerce-functions
#'
#' @return \code{qreduceSummarizedExperiment} has \code{rowRanges()}
#'     identical to \code{query}, and \code{assay()} data as
#'     \code{qreduceAssay()}.
#'
#' @export
qreduceSummarizedExperiment <-
    function(x, query, simplifyReduce, i = 1L, withDimnames=TRUE)
{
    stopifnot_simplify_ok(simplifyReduce, 3L)
    if (missing(query))
        query <- rowRanges(x)

    i <- .assay_i(x, i)
    name <- assayNames(x)[[i]]
    assay <- qreduceAssay(x, query, simplifyReduce, i)
    rowRanges <- setNames(GRanges(rownames(assay)), rownames(assay))
    if (!withDimnames)
        assay <- unname(assay)
    assay <- setNames(list(assay), name)

    colData <- colData(x)
    if (!withDimnames) {
        names(rowRanges) <- rownames(colData) <- NULL
    }

    SummarizedExperiment(assay, rowRanges=rowRanges, colData=colData)
}


#' @rdname coerce-functions
#'
#' @name coerce-RaggedExperiment
#'
#' @aliases coerce,dgCMatrix,RaggedExperiment-method
#'
#' @section
#' sparseMatrix:
#'   Convert a `dgCMatrix` to a `RaggedExperiment` given that the rownames
#'   are coercible to `GRanges`.
#'
#' In the following example, `x` is a `dgCMatrix` from the `Matrix` package.
#' \preformatted{
#'     `as(x, "RaggedExperiment")`
#' }
#'
#' @md
#'
#' @examples
#'
#' sm <- Matrix::sparseMatrix(
#'     i = c(2, 3, 4, 3, 4, 3, 4),
#'     j = c(1, 1, 1, 3, 3, 4, 4),
#'     x = c(2L, 4L, 2L, 2L, 2L, 4L, 2L),
#'     dims = c(4, 4),
#'     dimnames = list(
#'         c("chr2:1-10", "chr2:2-10", "chr2:3-10", "chr2:4-10"),
#'         LETTERS[1:4]
#'     )
#' )
#'
#' as(sm, "RaggedExperiment")
#'
#' @exportMethod coerce

setAs("dgCMatrix", "RaggedExperiment",
    function(from) {
        dp <- diff(from@p)
        j <- rep.int(seq_along(dp), dp)
        idx <- from@i + 1
        x <- from@x

        ranges <- rownames(from)
        if (is.null(ranges) && length(x))
            stop("'rownames(x)' are NULL and not coercible to 'GRanges'")
        rgs <- try(GRanges(ranges[idx]), silent = TRUE)
        if (is(rgs, "try-error"))
            stop("'rownames(x)' are not coercible to 'GRanges'")
        mcols(rgs) <- DataFrame(counts = x)

        grls <- GRangesList(split(rgs, j))
        names(grls) <- colnames(from)[dp > 0]
        RaggedExperiment(grls)
    }
)
