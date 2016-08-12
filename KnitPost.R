KnitPost <- function(convert_file, date = Sys.Date(), 
                     fig.dir = "figures") {
  # convert_file: name/path to specific Rmd file to convert
  # date: String giving the date of the post in format "%Y-%m-%d"
  # fig.dir: directory to save figures
  
  # directory of blog's R project
  site.path <- getwd()
  # directory for converted markdown files
  posts.path <- file.path(site.path, "_posts")
  
  knitr::render_jekyll(highlight = "pygments")
  # "base.dir is never used when composing the URL of the figures; it is
  # only used to save the figures to a different directory, which can
  # be useful when you do not want the figures to be saved under the
  # current working directory.
  # The URL of an image is always base.url + fig.path"
  # https://groups.google.com/forum/#!topic/knitr/18aXpOmsumQ
  knitr::opts_knit$set(
    base.url = "/",
    base.dir = site.path)
  knitr::opts_chunk$set(
    fig.path   = fig.dir,
    fig.width  = 8.5,
    fig.height = 5.25,
    dev        = 'svg',
    cache      = FALSE,
    warning    = FALSE,
    message    = FALSE,
    tidy       = FALSE)
  
  # get the right name output format
  lines <- readLines(convert_file, encoding = "UTF-8")
  ind.title <- grep("title:", lines, fixed = TRUE)
  line.title <- sub("title:", "", lines[ind.title])
  line.title <- gsub('\"', "", line.title, fixed = TRUE)
  suffix <- gsub("[ ]{1,}", "-", line.title)
  
  md.path <- file.path(posts.path, paste0(date, suffix, ".md"))
  
  # KNITTING ====
  message(paste0("=== KnitPost(", convert_file, ")"))
  out.file <- knitr::knit(convert_file,
                          output = md.path,
                          envir = parent.frame(),
                          quiet = TRUE)
  
  # Get lines of md file
  lines <- readLines(out.file, encoding = "UTF-8")
  # Add layout
  header <- grep("---", x = lines, fixed = TRUE)
  lines[header[1]] <- paste0(lines[header[1]], "\n", "layout: post")
  # reform MathJax syntax
  lines <- gsub(pattern = "$", replacement = "$$", lines, fixed = TRUE)
  lines <- gsub(pattern = "$$$$", replacement = "\n\n$$\n\n", 
                lines, fixed = TRUE)
  writeLines(lines, out.file, useBytes = TRUE)
  
  return("DONE")
}

