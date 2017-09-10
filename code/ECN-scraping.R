library(pdftools)

txt <- pdf_text("http://www.remede.org/documents/IMG/pdf/liste_classement_ecn_20170628.pdf")



data <- unlist(gsubfn::strapply(txt, pattern = "([0-9]{4} [M\\.|Mme|Mlle].*?)\\r\\n"))

head(data)

library(stringr)
library(lubridate)
library(tidyverse)
res <- matrix(NA_character_, length(data), 7)

data_parsed <- str_extract_all(data, boundary("word"))
tmp <- sapply(data_parsed, head, n = 4)
res[, 1:4] <- t(sapply(data_parsed, head, n = 4))
res[, 5:7] <- t(sapply(data_parsed, tail, n = 3))

res2 <- as_tibble(res) %>%
  transmute(
    ranking = as.integer(V1),
    is_male = (V2 == "M"),
    family_name = V3,
    first_name = V4,
    birth_date = pmap(list(V5, V6, V7), function(d, m, y) {
      paste(d, m, y, collapse = " ")
    }) %>% lubridate::dmy()
  ) 

head(res2)
count(res2, is_male)

plot(cummean(res2$is_male), type = "l")
plot(cummean(res2$is_male), type = "l", xlim = c(0, 200))

head(res2)
ggplot(res2) +
  geom_histogram(aes(x = birth_date), bins = 100)
# +
#   xlim(ymd("1988-1-1"), ymd("1996-1-1")) 

(ggplot(res2, aes(ranking, birth_date)) +
    geom_point() +
    geom_smooth(aes(color = is_male), lwd = 2)) %>%
  plotly::ggplotly()
# geom_smooth(method = "lm") 

hist(res2$)
