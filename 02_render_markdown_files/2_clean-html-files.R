# manually edit some parts of the rendered html files that I don't yet know
# how to control when they are rendered from the .qmd source file



# load packages -----------------------------------------------------------
## use pacman package
if (!require(pacman)) {install.packages(pacman)}

### using p_load() instead of library() to check whether packages are installed 
### before loading, and download / install if not 
p_load(here)
p_load(tidyverse)



# get list of html files --------------------------------------------------
files_list <- list.files(path = here("docs", "projects"))




# edit --------------------------------------------------------------------
walk(
  .x = files_list,
  .f = ~ read_file(here("docs", "projects", .x)) |>
    ## change "Author" heading to "Team Members" ----
    str_replace_all(
      pattern = '<div class="quarto-title-meta-heading">Authors</div><div class="quarto-title-meta-contents"><div class="quarto-title-authors">',
      replacement = '<div class="quarto-title-meta-heading">Team Members</div><div class="quarto-title-meta-contents"><div class="quarto-title-authors">'
    ) |>
    str_replace_all(
      pattern = '<div class="quarto-title-meta-heading">Author</div><div class="quarto-title-meta-contents"><div class="quarto-title-authors">',
      replacement = '<div class="quarto-title-meta-heading">Team Members</div><div class="quarto-title-meta-contents"><div class="quarto-title-authors">'
    ) |>
    ## change "Published" heading to "Year" ----
    str_replace_all(
      pattern = '<div class="quarto-title-meta-heading">Published</div><div class="quarto-title-meta-contents">',
      replacement = '<div class="quarto-title-meta-heading">Year</div><div class="quarto-title-meta-contents">'
    ) |>
    ## save modified file ----
    write_file(
      file = here("docs", "projects", .x),
      append = FALSE
    )
)
