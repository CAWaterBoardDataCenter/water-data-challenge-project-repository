# load packages -----------------------------------------------------------
## use the pacman package
if (!require(pacman)) {install.packages('pacman'); library(pacman)}

## using p_load() instead of library() to check whether packages are installed
## before loading, and download / install if not
p_load(here)
p_load(servr)


# create markdown files ---------------------------------------------------
## (from info in project repository spreadsheet and template markdown files)
source(here(
  "02_render_markdown_files",
  "1_render-markdown-files.R"
))
rm(list = ls())


# render site -------------------------------------------------------------
shell("quarto render")


# edit html files ---------------------------------------------------------
source(here(
  "02_render_markdown_files",
  "2_clean-html-files.R"
))


# preview site ------------------------------------------------------------
httd(here("docs")) # start the local web server
# daemon_stop(1) # stop the local web server
