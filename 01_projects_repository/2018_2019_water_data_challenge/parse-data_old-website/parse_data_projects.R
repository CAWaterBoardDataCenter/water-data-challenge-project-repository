
# load packages -----------------------------------------------------------
library(tidyverse)
library(here)
library(writexl)


# get awards and topics info (parsed with other scripts) ------------------
## may want to merge this with the projects data
awards_data <- read_csv(here('_projects_repository', 
                             'old-website_awards.csv'), 
                        col_types = cols(.default = col_character()))
### create a project name lookup
proj_name_lookup <- awards_data$award_name |> setNames(awards_data$award_slug)

topics_data <- read_csv(here('_projects_repository', 
                             'old-website_topics.csv'), 
                        col_types = cols(.default = col_character()))


# get list of markdown files ----------------------------------------------
md_location <- here('_projects_repository', 
                    'wadaco-website-hugo-source-master', 
                    'content', 
                    'project')
md_files <- list.files(md_location)


# parse markdown files ----------------------------------------------------
parsed_md <- map_df(.x = md_files, 
             .f = function(x) {
                 ## read file
                 file_lines <- read_lines(file.path(md_location, x)) |>
                     iconv(to = 'UTF-8')
                 # file_lines <- readLines(con = file.path(md_location, x), encoding = 'Latin-1') #|> 
                 #     # iconv(to = 'UTF-8')
                 
                 ## extract header info
                 proj_title <- file_lines[str_detect(string = file_lines, pattern = 'title:')] |> 
                     str_remove(pattern = 'title:') |> 
                     str_remove_all(pattern = "'") |> 
                     str_trim()
                 
                 team_name <- file_lines[grep('team:', x = file_lines) + 1] |> 
                     str_remove(pattern = 'name:') |> 
                     str_trim()
                 team_name <- ifelse(str_detect(string = team_name, 
                                                pattern = '^repo:'), 
                                     '', 
                                     team_name)
                 
                 team_members <- file_lines[str_detect(string = file_lines, pattern = '- name:')] |> 
                     str_remove_all(pattern = '- name:') |> 
                     str_remove_all(pattern = "'") |> 
                     str_remove_all(pattern = "'") |> 
                     str_remove_all(pattern = '"') |> 
                     # iconv(to = 'UTF-8') |> 
                     str_replace(pattern = '\\\\xE9', replacement = 'é') |> 
                     str_trim()
                 loc_authors <- grep('authors:', x = file_lines)
                 loc_team <- grep('team:', x = file_lines)
                 team_members_url <- file_lines[(loc_authors + 1):(loc_team - 1)] |> 
                     str_remove_all(pattern = '- name: ')
                 team_members_url <- team_members_url[str_detect(team_members_url, ' url:')] |> 
                     str_remove_all(pattern = 'url:') |> 
                     str_remove_all(pattern = "'") |> 
                     str_remove_all(pattern = '"') |> 
                     # iconv(to = 'UTF-8') |> 
                     str_trim() 
                 team_members_with_url <- team_members[team_members_url != '']
                 team_members_without_url <- team_members[team_members_url == '']
                 team_members_url <- team_members_url[team_members_url != '']
                 team_members_url <- paste0('(', team_members_url, ')')
                 team_members_url <- paste0('[',team_members_with_url,']', team_members_url) |> 
                     str_remove_all('\\[\\]\\(\\)')
                 team_members_url <- c(team_members_url, team_members_without_url)
                 team_members_url <- team_members_url[team_members_url != '']
                 
                 
                 proj_repo <- file_lines[str_detect(string = file_lines, pattern = 'repo:')] |> 
                     str_remove_all(pattern = 'repo:') |> 
                     str_remove(pattern = "''") |> 
                     str_trim()
                 proj_repo[proj_repo == 'https://github.com/waterdatacollaborative/'] <- ''
                 
                 ## find start location of 'topics', 'initiatives', and 'awards'
                 loc_topics <- grep('topics:', x = file_lines)
                 loc_initiatives <- grep('initiatives:', x = file_lines)
                 loc_awards <- grep('awards:', x = file_lines)
                 
                 ## get topics, initiatives, and awards
                 proj_topics <- file_lines[(loc_topics + 1):(loc_initiatives - 1)] |> 
                     str_remove_all(pattern = '- ') |> 
                     str_trim() |> 
                     str_to_title()
                 proj_initiatives <- file_lines[(loc_initiatives + 1):(loc_awards - 1)] |> 
                     str_remove_all(pattern = '- ') |> 
                     str_trim()
                 proj_year <- parse_number(proj_initiatives)
                 proj_awards <- file_lines[(loc_awards):(grep('weight:', x = file_lines) - 1)] |> 
                     # file_lines[str_detect(string = file_lines, pattern = 'awards:')] |> 
                     str_remove(pattern = 'awards:') |> 
                     str_remove(pattern = '\\[\\]') |> 
                     str_remove_all('- ') |> 
                     str_trim()
                 proj_awards <- proj_awards[!proj_awards == '']
                 proj_awards_plaintext <- str_replace_all(string = proj_awards, 
                                                          pattern = proj_name_lookup)
                 
                 ## get description
                 loc_sec_2 <- grep('--', x = file_lines)[2]
                 proj_description <- file_lines[(loc_sec_2 + 1):length(file_lines)] |> 
                     str_remove_all(pattern = '### ') |> 
                     paste(collapse = '\n') |> 
                     str_trim()
                 
                 ## combine all elements into a dataframe
                 parse_output <- tibble(
                     title = proj_title,
                     team_name = team_name,
                     team_members = paste(team_members, collapse = ' | '),
                     team_members_url = paste(team_members_url, collapse = ' | '), 
                     repo = proj_repo,
                     topics = paste(proj_topics, collapse = ' | '), 
                     # initiatives = paste(proj_initiatives, collapse = ' | '),
                     year = proj_year, 
                     # awards_code = paste(proj_awards, collapse = ' | '),
                     awards = paste(proj_awards_plaintext, collapse = ' | '),
                     description = proj_description
                 )
                 
                 return(parse_output)
             }
             )



## filter out the GreenGov Challenge (the md has no real info for this project)
parsed_md <- parsed_md |> 
    filter(title != 'GreenGov Challenge')

View(parsed_md)


# write output file -------------------------------------------------------
write_csv(x = parsed_md,
          file = here('_projects_repository', 'old-website_projects.csv'))

write_xlsx(x = parsed_md, 
           path = here('_projects_repository', 'old-website_projects.xlsx'))





### TESTING ###
# individual file ---------------------------------------------------------
md_file_current <- md_files[8]
file_lines <- read_lines(file.path(md_location, md_file_current))

proj_title <- file_lines[str_detect(string = file_lines, pattern = 'title:')] |> 
    str_remove(pattern = 'title: ')
team_name <- file_lines[grep('team: ', x = file_lines) + 1] |> 
    str_remove(pattern = '  name: ')
team_name <- ifelse(str_detect(string = team_name, 
                               pattern = '^repo:'), 
                    '', 
                    team_name)


team_members <- file_lines[str_detect(string = file_lines, pattern = '- name:')] |> 
    str_remove_all(pattern = '- name: ')

team_members <- file_lines[str_detect(string = file_lines, pattern = '- name:')] |> 
    str_remove_all(pattern = '- name:') |> 
    str_remove_all(pattern = "'") |> 
    str_remove_all(pattern = "'") |> 
    str_remove_all(pattern = '"') |> 
    iconv(to = 'UTF-8') |> 
    str_replace(pattern = '\\\\xE9', replacement = 'é') |> 
    str_trim()


loc_authors <- grep('authors:', x = file_lines)
loc_team <- grep('team:', x = file_lines)
team_members_url <- file_lines[(loc_authors + 1):(loc_team - 1)] |> 
    str_remove_all(pattern = '- name: ')
team_members_url <- team_members_url[str_detect(team_members_url, ' url:')] |> 
    str_remove_all(pattern = 'url:') |> 
    str_remove_all(pattern = "'") |> 
    str_trim() 
team_members_with_url <- team_members[team_members_url != '']
team_members_without_url <- team_members[team_members_url == '']

team_members_url <- team_members_url[team_members_url != '']
team_members_url <- paste0('(', team_members_url, ')')
team_members_url <- paste0('[',team_members_with_url,']', team_members_url) |> 
    str_remove_all('\\[\\]\\(\\)')
team_members_url <- c(team_members_url, team_members_without_url)
team_members_url <- team_members_url[team_members_url != '']


proj_repo <- file_lines[str_detect(string = file_lines, pattern = 'repo:')] |> 
    str_remove_all(pattern = 'repo: ') |> 
    str_remove(pattern = "''")

# find start location of 'topics' and 'initiatives'
loc_topics <- grep('topics:', x = file_lines)
loc_initiatives <- grep('initiatives:', x = file_lines)
loc_awards <- grep('awards:', x = file_lines)


# get topics and initiatives
proj_topics <- file_lines[(loc_topics + 1):(loc_initiatives - 1)] |> 
    str_remove_all(pattern = '- ')
proj_initiatives <- file_lines[(loc_initiatives + 1):(loc_awards - 1)] |> 
    str_remove_all(pattern = '- ')
proj_year <- parse_number(proj_initiatives)
proj_awards <- file_lines[(loc_awards):(grep('weight:', x = file_lines) - 1)] |> 
    # file_lines[str_detect(string = file_lines, pattern = 'awards:')] |> 
    str_remove(pattern = 'awards:') |> 
    str_remove(pattern = '\\[\\]') |> 
    str_remove(pattern = '- ') |> 
    str_trim()
proj_awards <- proj_awards[!proj_awards == '']

## get plain-text name of award
### method 1 
proj_awards_plaintext_1 <- str_replace_all(string = proj_awards, pattern = proj_name_lookup)
### method 2
proj_awards_plaintext_2 <- proj_awards
for (i in seq(awards_data$award_slug)) {
    proj_awards_plaintext_2 <-  str_replace_all(string = proj_awards_plaintext_2, 
                                              pattern = awards_data$award_slug[i], 
                                              replacement = awards_data$award_name[i])
}






# get description
loc_sec_2 <- grep('--', x = file_lines)[2]
proj_description <- file_lines[(loc_sec_2 + 1):length(file_lines)] |> 
    paste(collapse = '\n')

parse_output <- tibble(
    title = proj_title,
    team_name = team_name,
    team_members = paste(team_members, collapse = ' | '),
    topics = paste(proj_topics, collapse = ' | '), 
    initiatives = paste(proj_initiatives, collapse = ' | '),
    awards = paste(proj_awards, collapse = ' | '),
    description = proj_description
)
View(parse_output)
