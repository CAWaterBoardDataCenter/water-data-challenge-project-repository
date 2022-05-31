**\### This is a draft \###**

## Water Data Challenge Project Repository Website - Source Files

This repository contains the source files used to build a website that serves as a repository of projects submitted to the [California Water Data Challenge](https://waterchallenge.data.ca.gov/) in previous years. The website is available at: <https://daltare.github.io/water-data-challenge-project-repository/>

The website is built with the Quarto publishing system. See the [Quarto website](https://quarto.org/) for more information not covered here about how to modify/customize/render/publish sites using this system.

### Instructions

[To do: add a general workflow description - e.g., use of template markdown file with 'parameter' tags, script to build the project specific markdown files from the template markdown file and the project info spreadsheet/database...]

Specific instructions:

1.  Enter / edit project information in the `_projects_repository/projects_table` spreadsheet.

    -   Make sure to follow the formatting instructions

    -   You can enter information using [markdown formatting](https://www.markdownguide.org/basic-syntax/)

    -   Associated information may also be added in the `_projects_repository/awards_table` and `_projects_repository/topics_table` spreadsheets (you'll need to edit the scripts and/or templates in the steps below to make use of these tables)

2.  (Optional) If you want to change the information displayed in the project specific pages, edit the template markdown file (`render_project_qmd_files/project_template.txt`). If you do this, you need to make sure that the edits are consistent with the script that builds the markdown files (`render_project_qmd_files/1_render-qmd-files.R`), or edit the script as needed.

3.  Run the script (`render_project_qmd_files/1_render-qmd-files.R`) to generate the new project specific `.qmd` files in the `projects` folder.

    -   NOTE: this overwrites the existing files in this folder, so as a general rule don't make manual edits to these files (instead make changes to the project spreadsheet/database, markdown template, or other supporting files as needed)

4.  (Optional) You can add new 'main' pages to the website by creating new `.qmd` files in the main project directory (see the `index.qmd` and `about.qmd` files as examples). Then add references to these files in the `_quarto.yml` file (again following the example of the way it's done for the `index.qmd` and `about.qmd` files).

5.  Render the website.

    -   If using RStudio, open the project file (`.Rproj`), go to the `Build` tab (near the upper right side of the window), and click the `Render Website` button. NOTE: if you already had RStudio open from the previous steps, you may need to close and re-start RStudio prior to this step.
    -   More general instructions for rendering quarto websites with other tools / methods are available on the [quarto website](https://quarto.org/)

6.  Run the `render_project_qmd_files/2_clean-html-files.R` script to 'manually' clean some formatting/headers in the rendered html files.

7.  Push the changes to the GitHub repository.

    -   Note: if you wanted to create a new website in a different repository, you'd need to follow [these instructions](https://quarto.org/docs/websites/publishing-websites.html#github-pages) to set up GitHub pages correctly. You can ignore this if you're just making updates to this existing site.
