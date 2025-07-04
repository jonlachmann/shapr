% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compute_vS.R
\name{compute_vS}
\alias{compute_vS}
\title{Computes \code{v(S)} for all features subsets \code{S}.}
\usage{
compute_vS(internal, model, predict_model)
}
\arguments{
\item{internal}{List.
Not used directly, but passed through from \code{\link[=explain]{explain()}}.}
}
\value{
List of \code{v(S)} for different coalitions \code{S}, optionally also with the samples used to estimate \code{v(S)}
}
\description{
Computes \code{v(S)} for all features subsets \code{S}.
}
\keyword{internal}
