% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/explain.R
\name{explain}
\alias{explain}
\title{Explain the output of machine learning models with dependence-aware (conditional/observational) Shapley values}
\usage{
explain(
  model,
  x_explain,
  x_train,
  approach,
  phi0,
  iterative = NULL,
  max_n_coalitions = NULL,
  group = NULL,
  n_MC_samples = 1000,
  seed = NULL,
  verbose = "basic",
  predict_model = NULL,
  get_model_specs = NULL,
  prev_shapr_object = NULL,
  asymmetric = FALSE,
  causal_ordering = NULL,
  confounding = NULL,
  extra_computation_args = list(),
  iterative_args = list(),
  output_args = list(),
  ...
)
}
\arguments{
\item{model}{Model object.
Specifies the model whose predictions we want to explain.
Run \code{\link[=get_supported_models]{get_supported_models()}}
for a table of which models \code{explain} supports natively. Unsupported models
can still be explained by passing \code{predict_model} and (optionally) \code{get_model_specs},
see details for more information.}

\item{x_explain}{Matrix or data.frame/data.table.
Contains the the features, whose predictions ought to be explained.}

\item{x_train}{Matrix or data.frame/data.table.
Contains the data used to estimate the (conditional) distributions for the features
needed to properly estimate the conditional expectations in the Shapley formula.}

\item{approach}{Character vector of length \code{1} or one less than the number of features.
All elements should, either be \code{"gaussian"}, \code{"copula"}, \code{"empirical"}, \code{"ctree"}, \code{"vaeac"},
\code{"categorical"}, \code{"timeseries"}, \code{"independence"}, \code{"regression_separate"}, or \code{"regression_surrogate"}.
The two regression approaches can not be combined with any other approach.
See details for more information.}

\item{phi0}{Numeric.
The prediction value for unseen data, i.e. an estimate of the expected prediction without conditioning on any
features.
Typically we set this value equal to the mean of the response variable in our training data, but other choices
such as the mean of the predictions in the training data are also reasonable.}

\item{iterative}{Logical or NULL
If \code{NULL} (default), the argument is set to \code{TRUE} if there are more than 5 features/groups, and \code{FALSE} otherwise.
If eventually \code{TRUE}, the Shapley values are estimated iteratively in an iterative manner.
This provides sufficiently accurate Shapley value estimates faster.
First an initial number of coalitions is sampled, then bootsrapping is used to estimate the variance of the Shapley
values.
A convergence criterion is used to determine if the variances of the Shapley values are sufficiently small.
If the variances are too high, we estimate the number of required samples to reach convergence, and thereby add more
coalitions.
The process is repeated until the variances are below the threshold.
Specifics related to the iterative process and convergence criterion are set through \code{iterative_args}.}

\item{max_n_coalitions}{Integer.
The upper limit on the number of unique feature/group coalitions to use in the iterative procedure
(if \code{iterative = TRUE}).
If \code{iterative = FALSE} it represents the number of feature/group coalitions to use directly.
The quantity refers to the number of unique feature coalitions if \code{group = NULL},
and group coalitions if \code{group != NULL}.
\code{max_n_coalitions = NULL} corresponds to \code{max_n_coalitions=2^n_features}.}

\item{group}{List.
If \code{NULL} regular feature wise Shapley values are computed.
If provided, group wise Shapley values are computed.
\code{group} then has length equal to the number of groups.
The list element contains character vectors with the features included in each of the different groups.
See
\href{https://martinjullum.com/publication/jullum-2021-efficient/jullum-2021-efficient.pdf}{Jullum et al. (2021)}
for more information on group wise Shapley values.}

\item{n_MC_samples}{Positive integer.
For most approaches, it indicates the maximum number of samples to use in the Monte Carlo integration
of every conditional expectation.
For \code{approach="ctree"}, \code{n_MC_samples} corresponds to the number of samples
from the leaf node (see an exception related to the \code{ctree.sample} argument \code{\link[=setup_approach.ctree]{setup_approach.ctree()}}).
For \code{approach="empirical"}, \code{n_MC_samples} is  the \eqn{K} parameter in equations (14-15) of
Aas et al. (2021), i.e. the maximum number of observations (with largest weights) that is used, see also the
\code{empirical.eta} argument \code{\link[=setup_approach.empirical]{setup_approach.empirical()}}.}

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

\item{predict_model}{Function.
The prediction function used when \code{model} is not natively supported.
(Run \code{\link[=get_supported_models]{get_supported_models()}} for a list of natively supported models.)
The function must have two arguments, \code{model} and \code{newdata} which specify, respectively, the model
and a data.frame/data.table to compute predictions for.
The function must give the prediction as a numeric vector.
\code{NULL} (the default) uses functions specified internally.
Can also be used to override the default function for natively supported model classes.}

\item{get_model_specs}{Function.
An optional function for checking model/data consistency when \code{model} is not natively supported.
(Run \code{\link[=get_supported_models]{get_supported_models()}} for a list of natively supported models.)
The function takes \code{model} as argument and provides a list with 3 elements:
\describe{
\item{labels}{Character vector with the names of each feature.}
\item{classes}{Character vector with the classes of each features.}
\item{factor_levels}{Character vector with the levels for any categorical features.}
}
If \code{NULL} (the default) internal functions are used for natively supported model classes, and the checking is
disabled for unsupported model classes.
Can also be used to override the default function for natively supported model classes.}

\item{prev_shapr_object}{\code{shapr} object or string.
If an object of class \code{shapr} is provided, or string with a path to where intermediate results are stored,
then the function will use the previous object to continue the computation.
This is useful if the computation is interrupted or you want higher accuracy than already obtained, and therefore
want to continue the iterative estimation. See the
\href{https://norskregnesentral.github.io/shapr/articles/general_usage.html}{general usage vignette} for examples.}

\item{asymmetric}{Logical.
Not applicable for (regular) non-causal or asymmetric explanations.
If \code{FALSE} (default), \code{explain} computes regular symmetric Shapley values,
If \code{TRUE}, then \code{explain} compute asymmetric Shapley values based on the (partial) causal ordering
given by \code{causal_ordering}. That is, \code{explain} only uses the feature combinations/coalitions that
respect the causal ordering when computing the asymmetric Shapley values. If \code{asymmetric} is \code{TRUE} and
\code{confounding} is \code{NULL} (default), then \code{explain} computes asymmetric conditional Shapley values as specified in
\href{https://proceedings.neurips.cc/paper_files/paper/2020/file/0d770c496aa3da6d2c3f2bd19e7b9d6b-Paper.pdf}{
Frye et al. (2020)}. If \code{confounding} is provided, i.e., not \code{NULL}, then \code{explain} computes asymmetric causal
Shapley values as specified in
\href{https://proceedings.neurips.cc/paper/2020/file/32e54441e6382a7fbacbbbaf3c450059-Paper.pdf}{
Heskes et al. (2020)}.}

\item{causal_ordering}{List.
Not applicable for (regular) non-causal or asymmetric explanations.
\code{causal_ordering} is an unnamed list of vectors specifying the components of the
partial causal ordering that the coalitions must respect. Each vector represents
a component and contains one or more features/groups identified by their names
(strings) or indices (integers). If \code{causal_ordering} is \code{NULL} (default), no causal
ordering is assumed and all possible coalitions are allowed. No causal ordering is
equivalent to a causal ordering with a single component that includes all features
(\code{list(1:n_features)}) or groups (\code{list(1:n_groups)}) for feature-wise and group-wise
Shapley values, respectively. For feature-wise Shapley values and
\code{causal_ordering = list(c(1, 2), c(3, 4))}, the interpretation is that features 1 and 2
are the ancestors of features 3 and 4, while features 3 and 4 are on the same level.
Note: All features/groups must be included in the \code{causal_ordering} without any duplicates.}

\item{confounding}{Logical vector.
Not applicable for (regular) non-causal or asymmetric explanations.
\code{confounding} is a vector of logicals specifying whether confounding is assumed or not for each component in the
\code{causal_ordering}. If \code{NULL} (default), then no assumption about the confounding structure is made and \code{explain}
computes asymmetric/symmetric conditional Shapley values, depending on the value of \code{asymmetric}.
If \code{confounding} is a single logical, i.e., \code{FALSE} or \code{TRUE}, then this assumption is set globally
for all components in the causal ordering. Otherwise, \code{confounding} must be a vector of logicals of the same
length as \code{causal_ordering}, indicating the confounding assumption for each component. When \code{confounding} is
specified, then \code{explain} computes asymmetric/symmetric causal Shapley values, depending on the value of
\code{asymmetric}. The \code{approach} cannot be \code{regression_separate} and \code{regression_surrogate} as the
regression-based approaches are not applicable to the causal Shapley value methodology.}

\item{extra_computation_args}{Named list.
Specifies extra arguments related to the computation of the Shapley values.
See \code{\link[=get_extra_comp_args_default]{get_extra_comp_args_default()}} for description of the arguments and their default values.}

\item{iterative_args}{Named list.
Specifies the arguments for the iterative procedure.
See \code{\link[=get_iterative_args_default]{get_iterative_args_default()}} for description of the arguments and their default values.}

\item{output_args}{Named list.
Specifies certain arguments related to the output of the function.
See \code{\link[=get_output_args_default]{get_output_args_default()}} for description of the arguments and their default values.}

\item{...}{
  Arguments passed on to \code{\link[=setup_approach.categorical]{setup_approach.categorical}}, \code{\link[=setup_approach.copula]{setup_approach.copula}}, \code{\link[=setup_approach.ctree]{setup_approach.ctree}}, \code{\link[=setup_approach.empirical]{setup_approach.empirical}}, \code{\link[=setup_approach.gaussian]{setup_approach.gaussian}}, \code{\link[=setup_approach.independence]{setup_approach.independence}}, \code{\link[=setup_approach.regression_separate]{setup_approach.regression_separate}}, \code{\link[=setup_approach.regression_surrogate]{setup_approach.regression_surrogate}}, \code{\link[=setup_approach.timeseries]{setup_approach.timeseries}}, \code{\link[=setup_approach.vaeac]{setup_approach.vaeac}}
  \describe{
    \item{\code{categorical.joint_prob_dt}}{Data.table. (Optional)
Containing the joint probability distribution for each combination of feature
values.
\code{NULL} means it is estimated from the \code{x_train} and \code{x_explain}.}
    \item{\code{categorical.epsilon}}{Numeric value. (Optional)
If \code{categorical.joint_probability_dt} is not supplied, probabilities/frequencies are
estimated using \code{x_train}. If certain observations occur in \code{x_explain} and NOT in \code{x_train},
then epsilon is used as the proportion of times that these observations occurs in the training data.
In theory, this proportion should be zero, but this causes an error later in the Shapley computation.}
    \item{\code{internal}}{List.
Not used directly, but passed through from \code{\link[=explain]{explain()}}.}
    \item{\code{ctree.mincriterion}}{Numeric scalar or vector.
Either a scalar or vector of length equal to the number of features in the model.
The value is equal to 1 - \eqn{\alpha} where \eqn{\alpha} is the nominal level of the conditional independence tests.
If it is a vector, this indicates which value to use when conditioning on various numbers of features.
The default value is 0.95.}
    \item{\code{ctree.minsplit}}{Numeric scalar.
Determines minimum value that the sum of the left and right daughter nodes required for a split.
The default value is 20.}
    \item{\code{ctree.minbucket}}{Numeric scalar.
Determines the minimum sum of weights in a terminal node required for a split
The default value is 7.}
    \item{\code{ctree.sample}}{Boolean.
If \code{TRUE} (default), then the method always samples \code{n_MC_samples} observations from the leaf nodes
(with replacement).
If \code{FALSE} and the number of observations in the leaf node is less than \code{n_MC_samples},
the method will take all observations in the leaf.
If \code{FALSE} and the number of observations in the leaf node is more than \code{n_MC_samples},
the method will sample \code{n_MC_samples} observations (with replacement).
This means that there will always be sampling in the leaf unless
\code{sample = FALSE} \emph{and} the number of obs in the node is less than \code{n_MC_samples}.}
    \item{\code{empirical.type}}{Character. (default = \code{"fixed_sigma"})
Should be equal to either \code{"independence"},\code{"fixed_sigma"}, \code{"AICc_each_k"} \code{"AICc_full"}.
\code{"independence"} is deprecated. Use \code{approach = "independence"} instead.
\code{"fixed_sigma"} uses a fixed bandwidth (set through \code{empirical.fixed_sigma}) in the kernel density estimation.
\code{"AICc_each_k"} and \code{"AICc_full"} optimize the bandwidth using the AICc criterion, with respectively
one bandwidth per coalition size and one bandwidth for all coalition sizes.}
    \item{\code{empirical.eta}}{Numeric scalar.
Needs to be \verb{0 < eta <= 1}.
The default value is 0.95.
Represents the minimum proportion of the total empirical weight that data samples should use.
If e.g. \code{eta = .8} we will choose the \code{K} samples with the largest weight so that the sum of the weights
accounts for 80\\% of the total weight.
\code{eta} is the \eqn{\eta} parameter in equation (15) of
\href{https://martinjullum.com/publication/aas-2021-explaining/aas-2021-explaining.pdf}{Aas et al. (2021)}.}
    \item{\code{empirical.fixed_sigma}}{Positive numeric scalar.
The default value is 0.1.
Represents the kernel bandwidth in the distance computation used when conditioning on all different coalitions.
Only used when \code{empirical.type = "fixed_sigma"}}
    \item{\code{empirical.n_samples_aicc}}{Positive integer.
Number of samples to consider in AICc optimization.
The default value is 1000.
Only used for \code{empirical.type} is either \code{"AICc_each_k"} or \code{"AICc_full"}.}
    \item{\code{empirical.eval_max_aicc}}{Positive integer.
Maximum number of iterations when optimizing the AICc.
The default value is 20.
Only used for \code{empirical.type} is either \code{"AICc_each_k"} or \code{"AICc_full"}.}
    \item{\code{empirical.start_aicc}}{Numeric.
Start value of the \code{sigma} parameter when optimizing the AICc.
The default value is 0.1.
Only used for \code{empirical.type} is either \code{"AICc_each_k"} or \code{"AICc_full"}.}
    \item{\code{empirical.cov_mat}}{Numeric matrix. (Optional)
The covariance matrix of the data generating distribution used to define the Mahalanobis distance.
\code{NULL} means it is estimated from \code{x_train}.}
    \item{\code{gaussian.mu}}{Numeric vector. (Optional)
Containing the mean of the data generating distribution.
\code{NULL} means it is estimated from the \code{x_train}.}
    \item{\code{gaussian.cov_mat}}{Numeric matrix. (Optional)
Containing the covariance matrix of the data generating distribution.
\code{NULL} means it is estimated from the \code{x_train}.}
    \item{\code{regression.model}}{A \code{tidymodels} object of class \code{model_specs}. Default is a linear regression model, i.e.,
\code{\link[parsnip:linear_reg]{parsnip::linear_reg()}}. See \href{https://www.tidymodels.org/find/parsnip/}{tidymodels} for all possible models,
and see the vignette for how to add new/own models. Note, to make it easier to call \code{explain()} from Python, the
\code{regression.model} parameter can also be a string specifying the model which will be parsed and evaluated. For
example, \verb{"parsnip::rand_forest(mtry = hardhat::tune(), trees = 100, engine = "ranger", mode = "regression")"}
is also a valid input. It is essential to include the package prefix if the package is not loaded.}
    \item{\code{regression.tune_values}}{Either \code{NULL} (default), a data.frame/data.table/tibble, or a function.
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
    \item{\code{regression.vfold_cv_para}}{Either \code{NULL} (default) or a named list containing
the parameters to be sent to \code{\link[rsample:vfold_cv]{rsample::vfold_cv()}}. See the regression vignette for
several examples.}
    \item{\code{regression.recipe_func}}{Either \code{NULL} (default) or a function that that takes in a \code{\link[recipes:recipe]{recipes::recipe()}}
object and returns a modified \code{\link[recipes:recipe]{recipes::recipe()}} with potentially additional recipe steps. See the regression
vignette for several examples.
Note, to make it easier to call \code{explain()} from Python, the \code{regression.recipe_func} can also be a string
containing an R function. For example,
\code{"function(recipe) return(recipes::step_ns(recipe, recipes::all_numeric_predictors(), deg_free = 2))"} is also
a valid input. It is essential to include the package prefix if the package is not loaded.}
    \item{\code{regression.surrogate_n_comb}}{Positive integer.
Specifies the number of unique coalitions to apply to each training observation.
The default is the number of sampled coalitions in the present iteration.
Any integer between 1 and the default is allowed.
Larger values requires more memory, but may improve the surrogate model.
If the user sets a value lower than the maximum, we sample this amount of unique coalitions
separately for each training observations.
That is, on average, all coalitions should be equally trained.}
    \item{\code{timeseries.fixed_sigma}}{Positive numeric scalar.
Represents the kernel bandwidth in the distance computation.
The default value is 2.}
    \item{\code{timeseries.bounds}}{Numeric vector of length two.
Specifies the lower and upper bounds of the timeseries.
The default is \code{c(NULL, NULL)}, i.e. no bounds.
If one or both of these bounds are not \code{NULL}, we restrict the sampled time series to be between these bounds.
This is useful if the underlying time series are scaled between 0 and 1, for example.}
    \item{\code{vaeac.depth}}{Positive integer (default is \code{3}). The number of hidden layers
in the neural networks of the masked encoder, full encoder, and decoder.}
    \item{\code{vaeac.width}}{Positive integer (default is \code{32}). The number of neurons in each
hidden layer in the neural networks of the masked encoder, full encoder, and decoder.}
    \item{\code{vaeac.latent_dim}}{Positive integer (default is \code{8}). The number of dimensions in the latent space.}
    \item{\code{vaeac.lr}}{Positive numeric (default is \code{0.001}). The learning rate used in the \code{\link[torch:optim_adam]{torch::optim_adam()}} optimizer.}
    \item{\code{vaeac.activation_function}}{An \code{\link[torch:nn_module]{torch::nn_module()}} representing an activation function such as, e.g.,
\code{\link[torch:nn_relu]{torch::nn_relu()}} (default), \code{\link[torch:nn_leaky_relu]{torch::nn_leaky_relu()}}, \code{\link[torch:nn_selu]{torch::nn_selu()}}, or \code{\link[torch:nn_sigmoid]{torch::nn_sigmoid()}}.}
    \item{\code{vaeac.n_vaeacs_initialize}}{Positive integer (default is \code{4}). The number of different vaeac models to initiate
in the start. Pick the best performing one after \code{vaeac.extra_parameters$epochs_initiation_phase}
epochs (default is \code{2}) and continue training that one.}
    \item{\code{vaeac.epochs}}{Positive integer (default is \code{100}). The number of epochs to train the final vaeac model.
This includes \code{vaeac.extra_parameters$epochs_initiation_phase}, where the default is \code{2}.}
    \item{\code{vaeac.extra_parameters}}{Named list with extra parameters to the \code{vaeac} approach. See
\code{\link[=vaeac_get_extra_para_default]{vaeac_get_extra_para_default()}} for description of possible additional parameters and their default values.}
  }}
}
\value{
Object of class \code{c("shapr", "list")}. Contains the following items:
\describe{
\item{\code{shapley_values_est}}{data.table with the estimated Shapley values with explained observation in the rows and
features along the columns.
The column \code{none} is the prediction not devoted to any of the features (given by the argument \code{phi0})}
\item{\code{shapley_values_sd}}{data.table with the standard deviation of the Shapley values reflecting the uncertainty.
Note that this only reflects the coalition sampling part of the kernelSHAP procedure, and is therefore by
definition 0 when all coalitions is used.
Only present when \code{extra_computation_args$compute_sd=TRUE}, which is the default when \code{iterative = TRUE}}
\item{\code{internal}}{List with the different parameters, data, functions and other output used internally.}
\item{\code{pred_explain}}{Numeric vector with the predictions for the explained observations}
\item{\code{MSEv}}{List with the values of the MSEv evaluation criterion for the approach. See the
\href{https://norskregnesentral.github.io/shapr/articles/general_usage.html#msev-evaluation-criterion
}{MSEv evaluation section in the general usage for details}.}
\item{\code{timing}}{List containing timing information for the different parts of the computation.
\code{init_time} and \code{end_time} gives the time stamps for the start and end of the computation.
\code{total_time_secs} gives the total time in seconds for the complete execution of \code{explain()}.
\code{main_timing_secs} gives the time in seconds for the main computations.
\code{iter_timing_secs} gives for each iteration of the iterative estimation, the time spent on the different parts
iterative estimation routine.}
}
}
\description{
Computes dependence-aware Shapley values for observations in \code{x_explain} from the specified
\code{model} by using the method specified in \code{approach} to estimate the conditional expectation.
See \href{https://martinjullum.com/publication/aas-2021-explaining/aas-2021-explaining.pdf}{Aas et al. (2021)}
for a thorough introduction to dependence-aware prediction explanation with Shapley values.
For an overview of the methodology and capabilities of the package, see the software paper
\href{https://arxiv.org/pdf/2504.01842}{Jullum et al. (2025)}, or the pkgdown site at
\href{https://norskregnesentral.github.io/shapr/}{norskregnesentral.github.io/shapr/}.
}
\details{
The \code{shapr} package implements kernelSHAP estimation of dependence-aware Shapley values with
eight different Monte Carlo-based approaches for estimating the conditional distributions of the data.
These are all introduced in the
\href{https://norskregnesentral.github.io/shapr/articles/general_usage.html}{general usage vignette}.
(From R: \code{vignette("general_usage", package = "shapr")}).
For an overview of the methodology and capabilities of the package, please also see the software paper
\href{https://arxiv.org/pdf/2504.01842}{Jullum et al. (2025)}.
Moreover,
\href{https://martinjullum.com/publication/aas-2021-explaining/aas-2021-explaining.pdf}{Aas et al. (2021)}
gives a general introduction to dependence-aware Shapley values, and the three approaches \code{"empirical"},
\code{"gaussian"}, \code{"copula"}, and also discusses \code{"independence"}.
\href{https://martinjullum.com/publication/redelmeier-2020-explaining/redelmeier-2020-explaining.pdf}{
Redelmeier et al. (2020)} introduces the approach \code{"ctree"}.
\href{https://www.jmlr.org/papers/volume23/21-1413/21-1413.pdf}{Olsen et al. (2022)} introduces the \code{"vaeac"}
approach.
Approach \code{"timeseries"} is discussed in
\href{https://martinjullum.com/publication/jullum-2021-efficient/jullum-2021-efficient.pdf}{Jullum et al. (2021)}.
\code{shapr} has also implemented two regression-based approaches \code{"regression_separate"} and \code{"regression_surrogate"},
as described in \href{https://link.springer.com/content/pdf/10.1007/s10618-024-01016-z.pdf}{Olsen et al. (2024)}.
It is also possible to combine the different approaches, see the
\href{https://norskregnesentral.github.io/shapr/articles/general_usage.html}{
general usage} vignette for more information.

The package also supports the computation of causal and asymmetric Shapley values as introduced by
\href{https://proceedings.neurips.cc/paper/2020/file/32e54441e6382a7fbacbbbaf3c450059-Paper.pdf}{
Heskes et al. (2020)} and
\href{https://proceedings.neurips.cc/paper_files/paper/2020/file/0d770c496aa3da6d2c3f2bd19e7b9d6b-Paper.pdf}{
Frye et al. (2020)}.
Asymmetric Shapley values were proposed by
\href{https://proceedings.neurips.cc/paper_files/paper/2020/file/0d770c496aa3da6d2c3f2bd19e7b9d6b-Paper.pdf}{
Frye et al. (2020)} as a way to incorporate causal knowledge in
the real world by restricting the possible feature combinations/coalitions when computing the Shapley values to
those consistent with a (partial) causal ordering.
Causal Shapley values were proposed by
\href{https://proceedings.neurips.cc/paper/2020/file/32e54441e6382a7fbacbbbaf3c450059-Paper.pdf}{
Heskes et al. (2020)} as a way to explain the total effect of features
on the prediction, taking into account their causal relationships, by adapting the sampling procedure in \code{shapr}.

The package allows for parallelized computation with progress updates through the tightly connected
\link[future:future]{future::future} and \link[progressr:progressr]{progressr::progressr} packages.
See the examples below.
For iterative estimation (\code{iterative=TRUE}), intermediate results may also be printed to the console
(according to the \code{verbose} argument).
Moreover, the intermediate results are written to disk.
This combined batch computing of the v(S) values, enables fast and accurate estimation of the Shapley values
in a memory friendly manner.
}
\examples{
\donttest{

# Load example data
data("airquality")
airquality <- airquality[complete.cases(airquality), ]
x_var <- c("Solar.R", "Wind", "Temp", "Month")
y_var <- "Ozone"

# Split data into test- and training data
data_train <- head(airquality, -3)
data_explain <- tail(airquality, 3)

x_train <- data_train[, x_var]
x_explain <- data_explain[, x_var]

# Fit a linear model
lm_formula <- as.formula(paste0(y_var, " ~ ", paste0(x_var, collapse = " + ")))
model <- lm(lm_formula, data = data_train)

# Explain predictions
p <- mean(data_train[, y_var])

# (Optionally) enable parallelization via the future package
if (requireNamespace("future", quietly = TRUE)) {
  future::plan("multisession", workers = 2)
}


# (Optionally) enable progress updates within every iteration via the progressr package
if (requireNamespace("progressr", quietly = TRUE)) {
  progressr::handlers(global = TRUE)
}

# Empirical approach
explain1 <- explain(
  model = model,
  x_explain = x_explain,
  x_train = x_train,
  approach = "empirical",
  phi0 = p,
  n_MC_samples = 1e2
)

# Gaussian approach
explain2 <- explain(
  model = model,
  x_explain = x_explain,
  x_train = x_train,
  approach = "gaussian",
  phi0 = p,
  n_MC_samples = 1e2
)

# Gaussian copula approach
explain3 <- explain(
  model = model,
  x_explain = x_explain,
  x_train = x_train,
  approach = "copula",
  phi0 = p,
  n_MC_samples = 1e2
)

if (requireNamespace("party", quietly = TRUE)) {
  # ctree approach
  explain4 <- explain(
    model = model,
    x_explain = x_explain,
    x_train = x_train,
    approach = "ctree",
    phi0 = p,
    n_MC_samples = 1e2
  )
}

# Combined approach
approach <- c("gaussian", "gaussian", "empirical")
explain5 <- explain(
  model = model,
  x_explain = x_explain,
  x_train = x_train,
  approach = approach,
  phi0 = p,
  n_MC_samples = 1e2
)

# Print the Shapley values
print(explain1$shapley_values_est)

# Plot the results
if (requireNamespace("ggplot2", quietly = TRUE)) {
  plot(explain1)
  plot(explain1, plot_type = "waterfall")
}

# Group-wise explanations
group_list <- list(A = c("Temp", "Month"), B = c("Wind", "Solar.R"))

explain_groups <- explain(
  model = model,
  x_explain = x_explain,
  x_train = x_train,
  group = group_list,
  approach = "empirical",
  phi0 = p,
  n_MC_samples = 1e2
)
print(explain_groups$shapley_values_est)

# Separate and surrogate regression approaches with linear regression models.
req_pkgs <- c("parsnip", "recipes", "workflows", "rsample", "tune", "yardstick")
if (requireNamespace(req_pkgs, quietly = TRUE)) {
  explain_separate_lm <- explain(
    model = model,
    x_explain = x_explain,
    x_train = x_train,
    phi0 = p,
    approach = "regression_separate",
    regression.model = parsnip::linear_reg()
  )

  explain_surrogate_lm <- explain(
    model = model,
    x_explain = x_explain,
    x_train = x_train,
    phi0 = p,
    approach = "regression_surrogate",
    regression.model = parsnip::linear_reg()
  )
}

# Iterative estimation
# For illustration purposes only. By default not used for such small dimensions as here

# Gaussian approach
explain_iterative <- explain(
  model = model,
  x_explain = x_explain,
  x_train = x_train,
  approach = "gaussian",
  phi0 = p,
  n_MC_samples = 1e2,
  iterative = TRUE,
  iterative_args = list(initial_n_coalitions = 10)
)
}
\dontshow{
if (requireNamespace("future", quietly = TRUE)) {
  # R CMD check: make sure any open connections are closed afterward
  if (!inherits(future::plan(), "sequential")) future::plan("sequential")
}
}

}
\references{
\itemize{
\item \href{https://arxiv.org/pdf/2504.01842}{
Jullum, M., Olsen, L. H. B., Lachmann, J., & Redelmeier, A. (2025). shapr: Explaining Machine Learning Models
with Conditional Shapley Values in R and Python. arXiv preprint arXiv:2504.01842.}
\item \href{https://martinjullum.com/publication/aas-2021-explaining/aas-2021-explaining.pdf}{
Aas, K., Jullum, M., & Løland, A. (2021). Explaining individual predictions when features are dependent:
More accurate approximations to Shapley values. Artificial Intelligence, 298, 103502}
\item \href{https://proceedings.neurips.cc/paper_files/paper/2020/file/0d770c496aa3da6d2c3f2bd19e7b9d6b-Paper.pdf}{
Frye, C., Rowat, C., & Feige, I. (2020). Asymmetric Shapley values:
incorporating causal knowledge into model-agnostic explainability.
Advances in neural information processing systems, 33, 1229-1239}
\item \href{https://proceedings.neurips.cc/paper/2020/file/32e54441e6382a7fbacbbbaf3c450059-Paper.pdf}{
Heskes, T., Sijben, E., Bucur, I. G., & Claassen, T. (2020). Causal shapley values:
Exploiting causal knowledge to explain individual predictions of complex models.
Advances in neural information processing systems, 33, 4778-4789}
\item \href{https://martinjullum.com/publication/jullum-2021-efficient/jullum-2021-efficient.pdf}{
Jullum, M., Redelmeier, A. & Aas, K. (2021). Efficient and simple prediction explanations with
groupShapley: A practical perspective. Italian Workshop on Explainable Artificial Intelligence 2021.}
\item \href{https://martinjullum.com/publication/redelmeier-2020-explaining/redelmeier-2020-explaining.pdf}{
Redelmeier, A., Jullum, M., & Aas, K. (2020). Explaining predictive models with mixed features using Shapley
values and conditional inference trees. In Machine Learning and Knowledge Extraction:
International Cross-Domain Conference, CD-MAKE 2020, Dublin, Ireland, August 25-28, 2020, Proceedings 4
(pp. 117-137). Springer International Publishing.}
\item \href{https://www.theoj.org/joss-papers/joss.02027/10.21105.joss.02027.pdf}{
Sellereite N., & Jullum, M. (2019). shapr: An R-package for explaining machine learning models with
dependence-aware Shapley values. Journal of Open Source Software, 5(46), 2027}
\item \href{https://www.jmlr.org/papers/volume23/21-1413/21-1413.pdf}{
Olsen, L. H., Glad, I. K., Jullum, M., & Aas, K. (2022). Using Shapley values and variational autoencoders to
explain predictive models with dependent mixed features. Journal of machine learning research, 23(213), 1-51}
\item \href{https://link.springer.com/content/pdf/10.1007/s10618-024-01016-z.pdf}{
Olsen, L. H. B., Glad, I. K., Jullum, M., & Aas, K. (2024). A comparative study of methods for estimating
model-agnostic Shapley value explanations. Data Mining and Knowledge Discovery, 1-48}
\item \href{https://arxiv.org/pdf/2410.04883}{
Olsen, L. H. B., & Jullum, M. (2024). Improving the Sampling Strategy in KernelSHAP. arXiv e-prints, arXiv-2410}
}
}
\author{
Martin Jullum, Lars Henry Berge Olsen
}
