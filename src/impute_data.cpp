#include <RcppArmadillo.h>
using namespace Rcpp;

//' Get imputed data
//'
//' @param index_xtrain Positive integer. Represents a sequence of row indices from \code{x_train},
//' i.e. \code{min(index_xtrain) >= 1} and \code{max(index_xtrain) <= nrow(x_train)}.
//'
//' @param index_s Positive integer. Represents a sequence of row indices from \code{S},
//' i.e. \code{min(index_s) >= 1} and \code{max(index_s) <= nrow(S)}.
//'
//' @param x_explain Matrix with 1 row.
//' Contains the features of the observation for a single prediction.
//'
//' @param x_train Matrix.
//' Contains the training data.
//'
//' @details \code{S(i, j) = 1} if and only if feature \code{j} is present in feature
//' combination \code{i}, otherwise \code{S(i, j) = 0}. I.e. if \code{m = 3}, there
//' are \code{2^3 = 8} unique ways to combine the features. In this case \code{dim(S) = c(8, 3)}.
//' Let's call the features \code{x1, x2, x3} and take a closer look at the combination
//' represented by \code{s = c(x1, x2)}. If this combination is represented by the second row,
//' the following is true: \code{S[2, 1:3] = c(1, 1, 0)}.
//'
//' The returned object, \code{X}, is a numeric matrix where
//' \code{dim(X) = c(length(index_xtrain), ncol(x_train))}. If feature \code{j} is present in
//' the k-th observation, that is \code{S[index_[k], j] == 1}, \code{X[k, j] = x_explain[1, j]}.
//' Otherwise \code{X[k, j] = x_train[index_xtrain[k], j]}.
//'
//'
//' @inheritParams prepare_data_gaussian_cpp
//' @keywords internal
//'
//' @return Numeric matrix
//'
//' @author Nikolai Sellereite
// [[Rcpp::export]]
NumericMatrix observation_impute_cpp(IntegerVector index_xtrain,
                                     IntegerVector index_s,
                                     NumericMatrix x_train,
                                     NumericMatrix x_explain,
                                     IntegerMatrix S) {


    // Error-checks
    if (index_xtrain.length() != index_s.length())
        Rcpp::stop("The length of index_train and index_s should be equal.");

    if (x_train.ncol() != x_explain.ncol())
        Rcpp::stop("Number of columns in x_train and x_explain should be equal.");

    NumericMatrix X(index_xtrain.length(), x_train.ncol());

    for (int i = 0; i < X.nrow(); ++i) {

        for (int j = 0; j < X.ncol(); ++j) {

            if (S(index_s[i] - 1, j) > 0) {
                X(i, j) = x_explain(0, j);
            } else {
                X(i, j) = x_train(index_xtrain[i] - 1, j);
            }

        }
    }

    return X;
}
