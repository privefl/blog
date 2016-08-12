FormatPost <- function(convert_file, githubrepo) {
  # convert_file: name/path to specific file (any extension) to convert
  # githubrepo: string giving your repository name ex: "privefl"
  
  # without extension
  prefix <- tools::file_path_sans_ext(convert_file)
  # all 3 extensions
  rmd <- paste0(prefix, ".Rmd")
  md <- paste0(prefix, ".md")
  html <- paste0(prefix, ".html")
  
  # read files
  lines.rmd <- readLines(rmd, encoding = "UTF-8")
  lines.md <- readLines(md, encoding = "UTF-8")
  
  # get "header" (delimited by the first '***')
  header.md <- grep("***", x = lines.md, fixed = TRUE)[1]
  
  # get 'title', 'date' and 'layout' headers
  title <- grep("title:", lines.rmd, fixed = TRUE)
  date <- grep("date:", lines.rmd, fixed = TRUE)
  lines.md[1:(header.md - 1)] <- ""
  lines.md[1] <- paste("---", lines.rmd[title], lines.rmd[date], 
                       "layout: post", "---", "", sep = "\n")
  
  # get the right name output format
  line.title <- sub("title:", "", lines.rmd[title])
  line.title <- gsub('\"', "", line.title, fixed = TRUE)
  suffix <- gsub("[ ]{1,}", "-", line.title)
  md.path <- file.path("_posts", paste0(Sys.Date(), suffix, ".md"))
  
  
  # form MathJax syntax
  lines.md <- gsub(pattern = "$", replacement = "$$", lines.md, fixed = TRUE)
  lines.md <- gsub(pattern = "$$$$", replacement = "\n\n$$\n\n", 
                   lines.md, fixed = TRUE)
  
  # write ref to html from github
  lines.md[header.md] <- paste0("***\n\n", 
                                "<div style=\"text-align:center\">\n",
                                "<a target=\"_blank\" ",
                                "href=\"https://htmlpreview.github.io/?",
                                "https://github.com/",
                                githubrepo,
                                "/blog/blob/gh-pages/",
                                html,
                                "\">View this as a standalone HTML page</a>\n",
                                "</div>\n\n",
                                "***\n\n")
  
  # replace file with new lines
  writeLines(lines.md, md.path, useBytes = TRUE)
  
  return(md.path)
}

