square <- function(lim, ...) {
  segments(lim, lim, -lim , lim, ...)
  segments(lim, lim, lim , -lim, ...)
  segments(lim, -lim, -lim , -lim, ...)
  segments(-lim, -lim, -lim , lim, ...)
}