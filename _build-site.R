# load packages ----
library(here)
library(servr)

# create markdown files (from info in project repository spreadsheet) ----
source(here('02_render_markdown_files', 
            '1_render-markdown-files.R'))
rm(list = ls())

# render site ----
shell('quarto render')

# edit html files ----
source(here('02_render_markdown_files', 
            '2_clean-html-files.R'))

# (optional) preview site ----
httd(here('docs')) # start the local web server
daemon_stop(1) # stop the local web server
