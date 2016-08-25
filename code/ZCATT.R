ZCATT <- function(counts, x) {
  r <- sum(counts$cases[, 1])
  p <- counts$cases / r
  s <- sum(counts$controls[, 1])
  q <- counts$controls / s
  x <- c(0, x, 1)
  num <- colSums(x*(p - q))
  deno1 <- colSums(x^2*p) - (colSums(x*p))^2 
  deno2 <- colSums(x^2*q) - (colSums(x*q))^2 
  deno <- sqrt(deno1/r + deno2/s)
  num / deno
}