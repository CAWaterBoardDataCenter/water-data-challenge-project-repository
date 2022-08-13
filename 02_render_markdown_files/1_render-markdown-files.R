# create .qmd (quarto markdown) files, based on a template markdown file, and a
# spreadsheet/database of project information



# load packages -----------------------------------------------------------
# package_list <- c('here', 'tidyverse', 'janitor', 'readxl')
# ## check whether packages are installed, download and install if not 
# for (pkg in package_list) {
#     if (!require(pkg, character.only = TRUE)) {
#         install.packages(pkg)
#         library(pkg, character.only = TRUE)
#     }
# }

## use pacman package ----
if (!require(pacman)) {install.packages('pacman'); library(pacman)}

### using p_load() instead of library() to check whether packages are installed 
### before loading, and download / install if not 
p_load(here)
p_load(tidyverse)
p_load(janitor)
p_load(readxl)



# 1 - read input data ---------------------------------------------------------
## projects data ----
projects_data <- read_excel(
  path = here(
    "01_projects_repository",
    "project_repository_tables.xlsm"
  ),
  sheet = "projects_table",
  col_types = "text"
) |>
  clean_names()

### filter out projects to be excluded ----
projects_data <- projects_data |>
  filter(publish_to_website == TRUE)

### arrange by year ----
# projects_data <- projects_data %>%
#     arrange(year)

### add an ID field to uniquely identify each project ----
projects_data <- projects_data |>
  mutate(
    project_id = row_number(),
    .before = year
  )

## awards data ----
awards_data <- read_excel(
  path = here(
    "01_projects_repository",
    "project_repository_tables.xlsm"
  ),
  sheet = "awards_table",
  col_types = "text"
) |>
  clean_names()

### remove apostrophe from award names (may cause problems with categories) ----
awards_data <- awards_data |>
  mutate(award_name = str_replace_all(
    string = award_name,
    pattern = "'",
    replacement = ""
  ))

## topics data ----
topics_data <- read_excel(
  path = here(
    "01_projects_repository",
    "project_repository_tables.xlsm"
  ),
  sheet = "topics_table",
  col_types = "text"
) |>
  clean_names()

## events data ----
events_data <- read_excel(
  path = here(
    "01_projects_repository",
    "project_repository_tables.xlsm"
  ),
  sheet = "events_table",
  col_types = "text"
) |>
  clean_names()

## markdown templates ----
projects_template <- read_file(here(
  "02_render_markdown_files",
  "project_template.txt"
))

awards_template <- read_file(here(
  "02_render_markdown_files",
  "awards_template.txt"
))

topics_template <- read_file(here(
  "02_render_markdown_files",
  "topics_template.txt"
))

events_template <- read_file(here(
  "02_render_markdown_files",
  "events_template.txt"
))

# 2 - format project data -----------------------------------------------------

## add badge to awards ----
projects_data <- projects_data |>
  mutate(
    awards_full_names =
      reduce2(
        .x = awards_data$award_name,
        .y = paste0('"', awards_data$award_name, " ",
                    awards_data$award_badge, '"'),
        .init = projects_data$awards,
        .f = str_replace_all
      )
  )

## modify topics field ----
projects_data <- projects_data |>
  mutate(topics = case_when(
    !is.na(topics) ~ paste0('"Topic: ', topics, '"'),
    TRUE ~ topics
  )) |>
  mutate(topics = str_replace_all(
    string = topics,
    pattern = " \\| ",
    replacement = '" \\| "Topic: '
  ))

## add categories field (combine awards and topics) ----
projects_data <- projects_data |>
  mutate(event = paste0('"', event, '"')) |>
  mutate(categories = case_when(
    !is.na(awards_full_names) & !is.na(topics) ~
      paste(event, awards_full_names, topics, sep = " | "),
    !is.na(awards_full_names) ~ paste(event, awards_full_names, sep = " | "),
    !is.na(topics) ~ paste(event, topics, sep = " | "),
    TRUE ~ event
  ))

## replace NAs with 'NA' ----
projects_data <- projects_data %>%
  mutate(across(
    .cols = where(is.character),
    .fns = ~ replace_na(
      data = .,
      replace = "NA"
    )
  ))

## check ----
# glimpse(projects_data)
# View(projects_data)



# 3 - create project-specific qmd files ---------------------------------------

## delete existing qmd files ----
if (length(list.files(here("projects"))) > 0) {
  unlink(x = here("projects", list.files(here("projects"))))
}

## create new qmd files ----
pwalk(
  .l = list(
    projects_data$project_id, # ..1
    projects_data$title, # ..2
    projects_data$description, # ..3
    projects_data$team_members, # ..4
    projects_data$year, # ..5
    projects_data$categories, # ..6
    projects_data$topics, # ..7
    projects_data$awards_full_names, # ..8
    projects_data$resources # ..9
  ),
  .f = ~ projects_template |>
    ### project title ----
    str_replace_all(
      pattern = "params-header_proj_title",
      replacement = paste0('"', ..2, '"')
    ) |>
    str_replace_all(
      pattern = "params-proj_title",
      replacement = ..2
    ) |>
    ### project description ----
    str_replace_all(
      pattern = "params-proj_description",
      replacement = ..3
    ) |>
    # str_replace_all(pattern = 'params-header_proj_description',
    #                 replacement = paste0('"', ..3, '"')) |>
    ### team members ----
    str_replace_all(
      pattern = "params-team_members",
      replacement = paste0(
        '\r\n  - "',
        ..4 |> str_replace_all(
          pattern = ", ",
          replacement = '"\r\n  - "'
        ),
        '"'
      )
    ) |>
    ### year / date ----
    # str_replace_all(pattern = 'params-year',
    #                 replacement = ..5) |>
    str_replace_all(
      pattern = "params-date",
      replacement = paste0('"', ..5, '-06-30"')
    ) |>
    ### categories ----
    str_replace_all(
      pattern = "params-categories",
      replacement = paste0(
        "\r\n  - ",
        ..6 |>
          str_replace_all(
            pattern = " \\| ",
            replacement = "\r\n  - "
          )
      )
    ) |>
    ### topics ----
    # str_replace_all(pattern = 'params-topics',
    #                 replacement = ..7) |>
    ### awards ----
    # str_replace_all(pattern = 'params-awards',
    #                 replacement = ..8) |>
    ### resources ----
    str_replace_all(
      pattern = "params-resources",
      replacement = ..9
    ) |>
    ### write output file ----
    write_file(file = here(
      "projects",
      paste0(
        ..2 |>
          make_clean_names() |>
          substr(
            start = 1,
            stop = 50
          ),
        ".qmd"
      )
    ))
)



# create awards qmd file --------------------------------------------------
awards_data <- awards_data |>
  # create rendered version of badge from unicode character - have to pass the
  # unicode character through the str_ command to render, not sure why
  mutate(
    awards_badge_render =
      str_replace_all(
        string = award_name,
        pattern = award_name,
        replacement = award_badge
      )
  ) |>
  # combine the rendered badge with the award name
  mutate(awards_full_names = paste0(award_name, " ", awards_badge_render))
# View(awards_data)


## create text for markdown file ----
awards_text <- paste0(
  awards_template,
  pmap_chr(
    .l = list(
      awards_data$award_name, # ..1
      awards_data$award_badge, # ..2
      awards_data$award_description, # ..3
      awards_data$awards_badge_render, # ..4
      awards_data$awards_full_names
    ), # ..5
    .f = ~ paste0(
      "## ", ..1, " ", ..4,
      "\r\n\r\n",
      ..3, "\r\n\r\n",
      "[", ..1,
      " Award Winners](index.qmd#category=",
      URLencode(paste0(..1, " ")),
      ..4,
      ")",
      "\r\n\r\n\r\n"
    )
  ) |>
    paste0(collapse = "")
)

## remove NAs from the text
awards_text <- str_remove_all(string = awards_text, "\r\n\r\nNA")

## remove the last 2 line breaks
awards_text <- substr(awards_text, start = 1, stop = nchar(awards_text) - 4)

## write markdown file ----
write_file(
  x = awards_text,
  file = here("awards.qmd")
)



# create topics qmd file --------------------------------------------------
##  !!!!!! NOT USED !!!!!!

## create text for markdown file ----
topics_text <- paste0(
  topics_template,
  pmap_chr(
    .l = list(
      topics_data$topic_name, # ..1
      topics_data$topic_description
    ), # ..2
    .f = ~ paste0(
      "## ", ..1,
      "\r\n\r\n",
      ..2, "\r\n\r\n",
      "[", ..1,
      " Projects](index.qmd#category=",
      URLencode(paste0("Topic: ", ..1, " ")),
      ")",
      "\r\n\r\n\r\n"
    )
  ) |>
    paste0(collapse = "")
)

## remove NAs from the text
topics_text <- str_remove_all(string = topics_text, "\r\n\r\nNA")

## remove the last 2 line breaks
topics_text <- substr(topics_text, start = 1, stop = nchar(topics_text) - 4)

## write markdown file ----
write_file(
  x = topics_text,
  file = here("topics.qmd")
)



# create events qmd file --------------------------------------------------

## create text for markdown file ----
events_text <- paste0(
  events_template,
  pmap_chr(
    .l = list(
      events_data$event_name, # ..1
      events_data$event_description
    ), # ..2
    .f = ~ paste0(
      "## ", ..1,
      "\r\n\r\n",
      ..2, "\r\n\r\n",
      "- [", ..1,
      " Projects](index.qmd#category=",
      URLencode(paste0(..1)),
      ")",
      "\r\n\r\n\r\n"
    )
  ) |>
    paste0(collapse = "")
)

## remove NAs from the text
events_text <- str_remove_all(string = events_text, "\r\n\r\nNA")

## remove the last 2 line breaks
events_text <- substr(events_text, start = 1, stop = nchar(events_text) - 4)

## write markdown file ----
write_file(
  x = events_text,
  file = here("events.qmd")
)
