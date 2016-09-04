### ALGO p84
simu_counts <- function(nsim = 1e5, r = 500, s = r, k = 0.1, 
                 p = 0.1, F = 0, lam2 = 1, model = "NULL") {
  # g0 = q^2 + pqF, g1 = 2pq(1− F), and g2 = p^2 + pqF (p62)
  q <- 1 - p
  g0 <- q^2 + p*q*F
  g1 = 2*p*q*(1 - F)
  g2 = p^2 + p*q*F
  
  # REC: lambda1 = 1, ADD: lambda1 = (1 + lambda2)/2, 
  # MUL: lambda1 = lambda2^(1/2) and DOM: lambda1 = lambda2 (p63)
  if (model == "NULL") {
    lam1 <- lam2 <- 1
  } else if (model == "REC") {
    lam1 <- 1
  } else if (model == "ADD") {
    lam1 <- (1 + lam2)/2
  } else if (model == "MUL") {
    lam1 <- sqrt(lam2)
  } else if (model == "DOM") {
    lam1 <- lam2
  } else {
    stop("Choose model within NULL, RED, ADD, MUL or DOM")
  }
  
  # f0 = k/(g0 + lambda1 g1 + lambda2 g2), f1 = lambda1 f0, and f2 = lambda2 f0;
  f0 <- k/(g0 + lam1*g1 + lam2*g2)
  f1 <- lam1*f0
  f2 <- lam2*f0
  
  # pj = gjfj/k and qj = gj(1− fj )/(1 −k) for j = 0, 1, 2;
  p0 <- g0*f0/k
  p1 <- g1*f1/k
  p2 <- g2*f2/k
  q0 <- g0*(1 - f0)/(1 - k)
  q1 <- g1*(1 - f1)/(1 - k)
  q2 <- g2*(1 - f2)/(1 - k)
  
  # Generate random samples (r0, r1, s2) and (s0, s1, s2) 
  # independently from the multinomial distributions 
  # Mul(r;p0,p1,p2) and Mul(s; q0, q1, q2), respectively.
  counts <- list()
  counts$cases <- rmultinom(nsim, r, c(p0, p1, p2)) 
  counts$controls <- rmultinom(nsim, s, c(q0, q1, q2)) 
  counts
}
