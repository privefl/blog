// [[Rcpp::depends(RcppEigen, bigmemory, BH)]]
#include <RcppEigen.h>
#include <bigmemory/MatrixAccessor.hpp>

using namespace Rcpp;


/******************************************************************************/

// [[Rcpp::export]]
NumericVector prod2(XPtr<BigMatrix> bMPtr, const NumericVector& x) {
  
  MatrixAccessor<char> macc(*bMPtr);
  
  int n = bMPtr->nrow();
  int m = bMPtr->ncol();
  
  NumericVector res(n);
  int i, j;
  
  for (j = 0; j <= m - 2; j += 2) {
    for (i = 0; i < n; i++) { // unrolling optimization
      res[i] += x[j] * macc[j][i] + x[j+1] * macc[j+1][i];
    }
  }
  for (; j < m; j++) {
    for (i = 0; i < n; i++) {
      res[i] += x[j] * macc[j][i];
    }
  }
  
  return res;
}

/******************************************************************************/

// [[Rcpp::export]]
NumericVector prod8(XPtr<BigMatrix> bMPtr, const NumericVector& x) {
  
  MatrixAccessor<char> macc(*bMPtr);
  
  int n = bMPtr->nrow();
  int m = bMPtr->ncol();
  
  NumericVector res(n);
  int i, j;
  
  for (j = 0; j <= m - 8; j += 8) {
    for (i = 0; i < n; i++) { // unrolling optimization
      res[i] += ((x[j] * macc[j][i] + x[j+1] * macc[j+1][i]) +
        (x[j+2] * macc[j+2][i] + x[j+3] * macc[j+3][i])) +
        ((x[j+4] * macc[j+4][i] + x[j+5] * macc[j+5][i]) +
        (x[j+6] * macc[j+6][i] + x[j+7] * macc[j+7][i]));
    }
  }
  for (; j < m; j++) {
    for (i = 0; i < n; i++) {
      res[i] += x[j] * macc[j][i];
    }
  }
  
  return res;
}

/******************************************************************************/

// [[Rcpp::export]]
NumericVector prod16(XPtr<BigMatrix> bMPtr, const NumericVector& x) {
  
  MatrixAccessor<char> macc(*bMPtr);
  
  int n = bMPtr->nrow();
  int m = bMPtr->ncol();
  
  NumericVector res(n);
  int i, j;
  
  for (j = 0; j <= m - 16; j += 16) {
    for (i = 0; i < n; i++) { // unrolling optimization
      res[i] += (((x[j] * macc[j][i] + x[j+1] * macc[j+1][i]) +
        (x[j+2] * macc[j+2][i] + x[j+3] * macc[j+3][i])) +
        ((x[j+4] * macc[j+4][i] + x[j+5] * macc[j+5][i]) +
        (x[j+6] * macc[j+6][i] + x[j+7] * macc[j+7][i]))) +
        (((x[j+8] * macc[j+8][i] + x[j+9] * macc[j+9][i]) +
        (x[j+10] * macc[j+10][i] + x[j+11] * macc[j+11][i])) +
        ((x[j+12] * macc[j+12][i] + x[j+13] * macc[j+13][i]) +
        (x[j+14] * macc[j+14][i] + x[j+15] * macc[j+15][i])));
    }
  }
  for (; j < m; j++) {
    for (i = 0; i < n; i++) {
      res[i] += x[j] * macc[j][i];
    }
  }
  
  return res;
}

/******************************************************************************/
