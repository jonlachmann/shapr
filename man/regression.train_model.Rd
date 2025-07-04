% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/approach_regression_separate.R
\name{regression.train_model}
\alias{regression.train_model}
\title{Train a tidymodels model via workflows}
\usage{
regression.train_model(
  x,
  seed = 1,
  verbose = NULL,
  regression.model = parsnip::linear_reg(),
  regression.tune = FALSE,
  regression.tune_values = NULL,
  regression.vfold_cv_para = NULL,
  regression.recipe_func = NULL,
  regression.response_var = "y_hat",
  regression.surrogate_n_comb = NULL,
  current_comb = NULL
)
}
\arguments{
\item{x}{Data.table containing the training data.}

\item{seed}{Positive integer.
Specifies the seed before any randomness based code is being run.
If \code{NULL} (default) no seed is set in the calling environment.}

\item{verbose}{String vector or NULL.
Specifies the verbosity (printout detail level) through one or more of strings \code{"basic"}, \code{"progress"},
\code{"convergence"}, \code{"shapley"} and \code{"vS_details"}.
\code{"basic"} (default) displays basic information about the computation which is being performed,
in addition to some messages about parameters being sets or checks being unavailable due to specific input.
\verb{"progress} displays information about where in the calculation process the function currently is.
#' \code{"convergence"} displays information on how close to convergence the Shapley value estimates are
(only when \code{iterative = TRUE}) .
\code{"shapley"} displays intermediate Shapley value estimates and standard deviations (only when \code{iterative = TRUE})
and the final estimates.
\code{"vS_details"} displays information about the v_S estimates.
This is most relevant for \verb{approach \%in\% c("regression_separate", "regression_surrogate", "vaeac"}).
\code{NULL} means no printout.
Note that any combination of four strings can be used.
E.g. \code{verbose = c("basic", "vS_details")} will display basic information + details about the v(S)-estimation process.}

\item{regression.model}{A \code{tidymodels} object of class \code{model_specs}. Default is a linear regression model, i.e.,
\code{\link[parsnip:linear_reg]{parsnip::linear_reg()}}. See \href{https://www.tidymodels.org/find/parsnip/}{tidymodels} for all possible models,
and see the vignette for how to add new/own models. Note, to make it easier to call \code{explain()} from Python, the
\code{regression.model} parameter can also be a string specifying the model which will be parsed and evaluated. For
example, \verb{"parsnip::rand_forest(mtry = hardhat::tune(), trees = 100, engine = "ranger", mode = "regression")"}
is also a valid input. It is essential to include the package prefix if the package is not loaded.}

\item{regression.tune}{Logical (default is \code{FALSE}). If \code{TRUE}, then we are to tune the hyperparemeters based on
the values provided in \code{regression.tune_values}. Note that no checks are conducted as this is checked earlier in
\code{setup_approach.regression_separate} and \code{setup_approach.regression_surrogate}.}

\item{regression.tune_values}{Either \code{NULL} (default), a data.frame/data.table/tibble, or a function.
The data.frame must contain the possible hyperparameter value combinations to try.
The column names must match the names of the tunable parameters specified in \code{regression.model}.
If \code{regression.tune_values} is a function, then it should take one argument \code{x} which is the training data
for the current coalition and returns a data.frame/data.table/tibble with the properties described above.
Using a function allows the hyperparameter values to change based on the size of the coalition See the regression
vignette for several examples.
Note, to make it easier to call \code{explain()} from Python, the \code{regression.tune_values} can also be a string
containing an R function. For example,
\code{"function(x) return(dials::grid_regular(dials::mtry(c(1, ncol(x)))), levels = 3))"} is also a valid input.
It is essential to include the package prefix if the package is not loaded.}

\item{regression.vfold_cv_para}{Either \code{NULL} (default) or a named list containing
the parameters to be sent to \code{\link[rsample:vfold_cv]{rsample::vfold_cv()}}. See the regression vignette for
several examples.}

\item{regression.recipe_func}{Either \code{NULL} (default) or a function that that takes in a \code{\link[recipes:recipe]{recipes::recipe()}}
object and returns a modified \code{\link[recipes:recipe]{recipes::recipe()}} with potentially additional recipe steps. See the regression
vignette for several examples.
Note, to make it easier to call \code{explain()} from Python, the \code{regression.recipe_func} can also be a string
containing an R function. For example,
\code{"function(recipe) return(recipes::step_ns(recipe, recipes::all_numeric_predictors(), deg_free = 2))"} is also
a valid input. It is essential to include the package prefix if the package is not loaded.}

\item{regression.response_var}{String (default is \code{y_hat}) containing the name of the response variable.}

\item{regression.surrogate_n_comb}{Integer (default is \code{NULL}). The number of times each training observations
has been augmented. If \code{NULL}, then we assume that we are doing separate regression.}

\item{current_comb}{Integer vector. The current combination of features, passed to verbosity printing function.}
}
\value{
A trained \code{tidymodels} model based on the provided input parameters.
}
\description{
Function that trains a \code{tidymodels} model via \code{workflows} based on the provided input parameters.
This function allows for cross validating the hyperparameters of the model.
}
\author{
Lars Henry Berge Olsen
}
\keyword{internal}
