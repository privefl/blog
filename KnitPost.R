KnitPost <- function(convert_file, fig.dir = "figures") {
  # convert_file: name/path to specific Rmd file to convert
  # fig.dir: directory to save figures
  
  # directory of blog's R project
  site.path <- getwd()
  # directory where your Rmd-files reside (relative to base)
  rmd.path <- file.path(site.path, "_knitr")
  # directory for converted markdown files
  posts.path <- file.path(site.path, "_posts")
  
  knitr::render_jekyll(highlight = "prettify")
  # "base.dir is never used when composing the URL of the figures; it is
  # only used to save the figures to a different directory, which can
  # be useful when you do not want the figures to be saved under the
  # current working directory.
  # The URL of an image is always base.url + fig.path"
  # https://groups.google.com/forum/#!topic/knitr/18aXpOmsumQ
  opts_knit$set(
    base.url = "/",
    base.dir = site.path)
  opts_chunk$set(
    fig.path   = fig.dir,
    fig.width  = 8.5,
    fig.height = 5.25,
    dev        = 'svg',
    cache      = FALSE,
    warning    = FALSE,
    message    = FALSE,
    tidy       = FALSE)
  
  # convert a single Rmd file to markdown
  md.path <-
    file.path(posts.path, 
           basename(gsub(pattern = "\\.Rmd$",
                         replacement = ".md",
                         x = convert_file)))
  # KNITTING ====
  message(paste0("=== KnitPost(", convert_file, ")"))
  knitr::knit(convert_file,
              output = md.path,
              envir = parent.frame(),
              quiet = TRUE)
}