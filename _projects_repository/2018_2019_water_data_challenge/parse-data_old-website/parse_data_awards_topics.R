
# load packages -----------------------------------------------------------
library(tidyverse)
library(here)
library(writexl)



# awards ------------------------------------------------------------------
## get list of markdown files ----
md_location <- here('_projects_repository', 
                    'wadaco-website-hugo-source-master', 
                    'content', 
                    'awards')
md_files <- list.files(md_location)


## parse markdown files ----
parsed_md <- map_df(.x = md_files, 
             .f = function(x) {
                 ## read file
                 file_lines <- read_lines(file.path(md_location, x, '_index.md')) |>
                     iconv(to = 'UTF-8')
                 
                 award_name <- file_lines[str_detect(string = file_lines, pattern = 'name:')] |> 
                     str_remove(pattern = 'name:') |> 
                     str_trim()
                 award_slug <- file_lines[str_detect(string = file_lines, pattern = 'slug:')] |> 
                     str_remove(pattern = 'slug:') |> 
                     str_trim()
                 award_badge <- file_lines[str_detect(string = file_lines, pattern = 'badge:')] |> 
                     str_remove(pattern = 'badge:') |> 
                     str_remove_all(pattern = '"') |> 
                     str_trim()
                 
                 loc_sec_2 <- grep('---', x = file_lines)[2]
                 award_description <- file_lines[(loc_sec_2 + 1):length(file_lines)] 
                 award_description <- award_description[award_description != ''] |> 
                     paste(collapse = '\n')
                 if(loc_sec_2 == length(file_lines)) {award_description <- ''}
                 
                 ## combine all elements into a dataframe
                 parse_output <- tibble(
                     award_name = award_name, 
                     award_slug = award_slug, 
                     award_badge = award_badge, 
                     award_description = award_description
                 )
                 
                 return(parse_output)
             }
             )

View(parsed_md)

## write output file ----
write_csv(x = parsed_md, 
          file = here('_projects_repository', 'old-website_awards.csv'))

write_xlsx(x = parsed_md, 
           path = here('_projects_repository', 'old-website_awards.xlsx'))



# topics ------------------------------------------------------------------
## get list of markdown files ----
md_location <- here('_projects_repository', 
                    'wadaco-website-hugo-source-master', 
                    'content', 
                    'topics')
md_files <- list.files(md_location)
md_files <- md_files[md_files != '_index.md']

## parse markdown files ----
parsed_md <- map_df(.x = md_files, 
                    .f = function(x) {
                        ## read file
                        file_lines <- read_lines(file.path(md_location, x, '_index.md')) |>
                            iconv(to = 'UTF-8')
                        
                        topic_name <- file_lines[str_detect(string = file_lines, pattern = 'name:')] |> 
                            str_remove(pattern = 'name:') |> 
                            str_trim()
                        topic_slug <- file_lines[str_detect(string = file_lines, pattern = 'slug:')] |> 
                            str_remove(pattern = 'slug:') |> 
                            str_trim()
                        
                        loc_sec_2 <- grep('---', x = file_lines)[2]
                        topic_description <- file_lines[(loc_sec_2 + 1):length(file_lines)] 
                        topic_description <- topic_description[topic_description != ''] |> 
                            paste(collapse = '\n')
                        if(loc_sec_2 == length(file_lines)) {topic_description <- ''}

                        ## combine all elements into a dataframe
                        parse_output <- tibble(
                            topic_name = topic_name, 
                            topic_slug = topic_slug, 
                            topic_description = topic_description
                        )
                        
                        return(parse_output)
                    }
)

View(parsed_md)

## write output file ----
write_csv(x = parsed_md, 
          file = here('_projects_repository', 'old-website_topics.csv'))

write_xlsx(x = parsed_md, 
           path = here('_projects_repository', 'old-website_topics.xlsx'))




### TESTING ###
# individual file ---------------------------------------------------------

md_file_current <- md_files[4]
file_lines <- read_lines(file.path(md_location, md_file_current, '_index.md'))

topic_name <- file_lines[str_detect(string = file_lines, pattern = 'name:')] |> 
    str_remove(pattern = 'name:') |> 
    str_trim()
topic_slug <- file_lines[str_detect(string = file_lines, pattern = 'slug:')] |> 
    str_remove(pattern = 'slug:') |> 
    str_trim()

loc_sec_2 <- grep('---', x = file_lines)[2]
topic_description <- file_lines[(loc_sec_2 + 1):length(file_lines)] 
topic_description <- topic_description[topic_description != ''] |> 
    paste(collapse = '\n')
if(loc_sec_2 == length(file_lines)) {topic_description <- ''}
topic_description 
