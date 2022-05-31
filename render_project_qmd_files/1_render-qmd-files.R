# create .qmd (quarto markdown) files, based on a template markdown file, and a 
# spreadsheet/database of project information



# load packages -----------------------------------------------------------
library(tidyverse)
library(here)
library(janitor)
# library(quarto)
library(readxl)



# 1 - read input data ---------------------------------------------------------
## project data ----
projects_data <- read_excel(path = here('_projects_repository', 
                                        'projects_table.xlsm'), 
                            sheet = 'projects_table',
                            col_types = 'text') |> 
    clean_names()

### filter out projects to be excluded ----
projects_data <- projects_data |> 
    filter(publish_to_website == TRUE)

## arrange by year ----
# projects_data <- projects_data %>%
#     arrange(year)

### add an ID field to uniquely identify each project ----
projects_data <- projects_data |> 
    mutate(project_id = row_number(), 
           .before = year)

## awards data ----
awards_data <- read_excel(path = here('_projects_repository', 
                                      'awards_table.xlsx'), 
                          sheet = 'awards_table',
                          col_types = 'text') |> 
    clean_names()

## topics data ----
topics_data <- read_excel(path = here('_projects_repository', 
                                      'topics_table.xlsx'), 
                          sheet = 'topics_table',
                          col_types = 'text') |> 
    clean_names()

## markdown template ----
template_text <- read_file(here('render_project_qmd_files', 
                                'project_template.txt'))



# 2 - format project data -----------------------------------------------------
## add full awards name to projects (NOT USED) ---- #
# awards_data <- awards_data |> 
#     mutate(award_lookup = paste0('"', award_name, ' ', award_badge, '"'))
# 
# awards_names <-  projects_data$awards
# for (i in seq(projects_data$awards)) {
#     for (j in seq(awards_data$award_slug)) {
#         awards_names[i] <- str_replace_all(string = awards_names[i], 
#                                 pattern = awards_data$award_slug[j], 
#                                 replacement = awards_data$award_lookup[j])
#     }
# }

## add badge to awards (all same badge) ----
award_badge <- '\U0001F3C6'
projects_data <- projects_data |> 
    mutate(awards_full_names = case_when(!is.na(awards) ~ 
                                             paste0('"', 
                                                    awards, ' ', 
                                                    award_badge, '"'), 
                                         TRUE ~ awards)) |> 
    mutate(awards_full_names = str_replace_all(string = awards_full_names, 
                                               pattern = ' \\| ', 
                                               replacement = paste0(' ', award_badge, ' \\| ')))

## convert repo field into links ----
# projects_data <- projects_data |> 
#     mutate(repo = case_when(!is.na(repo) ~ paste0('<', repo, '>'), 
#                             TRUE ~ repo))

## modify topics field ----
projects_data <- projects_data |> 
    mutate(topics = case_when(!is.na(topics) ~ paste0('"Topic: ', topics, '"'), 
                              TRUE ~ topics)) |> 
    mutate(topics = str_replace_all(string = topics, 
                                    pattern = ' \\| ', 
                                    replacement = '" \\| "Topic: '))

## add categories field (combine awards and topics) ----
projects_data <- projects_data |> 
    mutate(event = paste0('"', event, '"')) |> 
    mutate(categories = case_when(!is.na(awards_full_names) & !is.na(topics) ~ 
                                      paste(event, awards_full_names, topics, sep = ' | '),
                                  !is.na(awards_full_names) ~ paste(event, awards_full_names, sep = ' | '),
                                  !is.na(topics) ~ paste(event, topics, sep = ' | '),
                                  TRUE ~ event)) 

## add note to projects with no description ----
# projects_data <- projects_data |> 
#     mutate(description = case_when(is.na(description) & !is.na(repo) ~ 'See project repository', 
#                             TRUE ~ description))

## replace NAs with 'NA' ----
projects_data <- projects_data %>%
    mutate(across(.cols = where(is.character), 
                  .fns = ~ replace_na(data = ., 
                                      replace = 'NA')))

## check --
# glimpse(projects_data)
# View(projects_data)




# 3 - create project-specific qmd files ---------------------------------------

## delete existing qmd files ----
if (length(list.files(here('projects'))) > 0) {
    unlink(x = here('projects', list.files(here('projects'))))
}

## create new qmd files ----
walk(.x = projects_data$project_id, 
     .f = ~ template_text |> 
         ### project title ----
     str_replace_all(pattern = 'params-header_proj_title' , 
                     replacement = paste0('"', 
                                          projects_data |> 
                                              filter(project_id == .x) |> 
                                              pull(title),
                                          '"')) |>
         str_replace_all(pattern = 'params-proj_title' , 
                         replacement = projects_data |> 
                             filter(project_id == .x) |> 
                             pull(title)) |> 
         ### project description ----
     str_replace_all(pattern = 'params-proj_description',
                     replacement = projects_data |>
                         filter(project_id == .x) |>
                         pull(description)) |>
         # str_replace_all(pattern = 'params-header_proj_description', 
         #                 replacement = paste0('"', 
         #                                      projects_data |> 
         #                                          filter(project_id == .x) |> 
         #                                          pull(description),
         #                                      '"')) |> 
         ### team members ----
     str_replace_all(pattern = 'params-team_members',
                     replacement = paste0('\r\n  - "',
                                          projects_data |>
                                              filter(project_id == .x) |>
                                              pull(team_members) |>
                                              str_replace_all(pattern = ', ',
                                                              replacement = '"\r\n  - "'),
                                          '"')) |>
         ### year / date ----
     # str_replace_all(pattern = 'params-year', 
     #                 replacement = projects_data |> 
     #                     filter(project_id == .x) |> 
     #                     pull(year)) |>
     str_replace_all(pattern = 'params-date',
                     replacement = paste0('"', projects_data |>
                                              filter(project_id == .x) |>
                                              pull(year),
                                          '-06-30"')) |>
     ### categories ----
     str_replace_all(pattern = 'params-categories',
                     replacement = paste0('\r\n  - ',
                                          projects_data |>
                                              filter(project_id == .x) |>
                                              pull(categories) |>
                                              str_replace_all(pattern = ' \\| ',
                                                              replacement = '\r\n  - '))) |>
     ### topics ----
     # str_replace_all(pattern = 'params-topics', 
     #                 replacement = projects_data |> 
     #                     filter(project_id == .x) |> 
     #                     pull(topics)) |> 
     ### awards ----
     # str_replace_all(pattern = 'params-awards', 
     #                 replacement = projects_data |> 
     #                     filter(project_id == .x) |> 
     #                     pull(awards_full_names)) |> 
     ### resources ----
     str_replace_all(pattern = 'params-resources',
                     replacement = projects_data |>
                         filter(project_id == .x) |>
                         pull(resources)) |>
     ### write output file ----
     write_file(file = here('projects', 
                            paste0(projects_data |>
                                       filter(project_id == .x) |>
                                       pull(project_id) |> 
                                       str_pad(width = 3, 
                                               side = 'left', 
                                               pad = 0), 
                                   '_', 
                                   projects_data |>
                                       filter(project_id == .x) |>
                                       pull(title) |> 
                                       make_clean_names() |> 
                                       substr(start = 1, 
                                              stop = 45), 
                                   '.qmd')))
)



# testing -----------------------------------------------------------------
# proj_test <- projects_data$title[1]
# z <- template_text |> 
#     str_replace_all(pattern = 'params-proj_title' , replacement = proj_test) |> 
#     str_replace_all(pattern = 'params-proj_description', replacement = projects_data |> filter(title == proj_test) |> pull(description)) |> 
#     str_replace_all(pattern = 'params-team_members', replacement = projects_data |> filter(title == proj_test) |> pull(team_members)) |> 
#     str_replace_all(pattern = 'params-year', replacement = projects_data |> filter(title == proj_test) |> pull(year)) |> 
#     str_replace_all(pattern = 'params-topics', replacement = projects_data |> filter(title == proj_test) |> pull(topics)) |> 
#     str_replace_all(pattern = 'params-awards', replacement = projects_data |> filter(title == proj_test) |> pull(awards)) |> 
#     str_replace_all(pattern = 'params-repository', replacement = projects_data |> filter(title == proj_test) |> pull(repo)) #|> 
#     # str_replace_all(pattern = '', replacement = projects_data |> filter(title == proj_test) |> pull()) |> 
#     # write_file(file = here('projects', paste0(proj_test |> make_clean_names(), '.qmd')))
# z
# View(z)
