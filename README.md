**\### This is a draft \###**

## Water Data Challenge Project Repository Website - Source Files

This repository contains the source files used to build a website that serves as a repository of projects submitted to the [California Water Data Challenge](https://waterchallenge.data.ca.gov/) in previous events. The website is available at: <https://cawaterboarddatacenter.github.io/water-data-challenge-project-repository/>

The website is built with the Quarto publishing system. See the [Quarto website](https://quarto.org/) for more information not covered here about how to modify/customize/render/publish sites using this system.

### Instructions

\[To do: add a general workflow description - e.g., use of template markdown file with 'parameter' tags, script to build the project specific markdown files from the template markdown file and the project info spreadsheet/database...\]

NOTE: this process overwrites most of the existing markdown files (i.e., files with a `.qmd` extension) in this directory, except for the `index.qmd` and `about.qmd` files. So, as a general rule, don't make manual edits to any markdown files except for the two listed above - instead make changes to the project repository workbook and the markdown template files as needed, then re-build the site as described below.

Specific instructions:

1.  Enter or edit project information in the `01_projects_repository/project_repository_tables` Excel workbook.

    -   The workbook contains multiple worksheets. Project specific information can be entered in the `projects_table` worksheet. Information about awards, topics, and events are in separate worksheets (`awards_table`, `topics_table`, and `events_table`) - these worksheets are linked to the `projects_table` worksheet in the sense that they provide the valid values for associated fields in the `projects_table` worksheet. Add new awards, topics, or events to these worksheets as needed.

    -   Make sure to follow the formatting instructions described in the workbook.

    -   You can enter information in the workbook using [markdown formatting](https://www.markdownguide.org/basic-syntax/).

2.  (Optional) If you need to change the format/layout of the project pages, you'll need to edit the template markdown file (`02_render_markdown_files/project_template.txt`). If you do this, you need to make sure that the edits are consistent with the script that builds the markdown files (`02_render_markdown_files/1_render-markdown-files.R`), or edit the script as needed.

3.  (Optional) You can also change the format/layout of the events, awards, and/or topics pages by editing the associated template markdown files (in the `02_render_markdown_files` folder), and editing the script that builds the markdown files (`02_render_markdown_files/1_render-markdown-files.R`) as needed.

4.  (Optional) You can add new 'main' pages to the website by creating new `.qmd` files in the main project directory (see the `index.qmd` and `about.qmd` files as examples). Then add references to these files in the `_quarto.yml` file (again following the example of the way it's done for the `index.qmd` and `about.qmd` files).

5.  Build the new version of the website by running the `_build-site.R` script. This script:

    -   Runs the `02_render_markdown_files/1_render-markdown-files.R` script to build markdown files based on the information in the project repository workbook and the template markdown files (the resulting markdown files are saved in the `projects` folder, and any previous versions of the markdown files in that folder are overwritten)

    -   Renders the site by converting the markdown files (`.qmd` files) into html files - the rendered files are generated in the `docs` folder

    -   Runs the `02_render_markdown_files/2_clean-html-files.R` script to do some minor editing of the rendered html files

    -   (Optional) Previews the site by running a local web server

    Any of these parts can also be run individually as needed.

    If using RStudio, as an alternative you can open the project file (`.Rproj`), go to the `Build` tab (near the upper right side of the window), and click the `Render Website` button. NOTE: if you already had RStudio open from the previous steps, you may need to close and re-start RStudio prior to this step.

    More general instructions for rendering quarto websites with other tools / methods are available on the [quarto website](https://quarto.org/)

6.  Push the changes to the GitHub repository.

    -   Note: if you wanted to create a new website in a different repository, you'd need to follow [these instructions](https://quarto.org/docs/websites/publishing-websites.html#github-pages) to set up GitHub pages correctly. But you can ignore this if you're just making updates to this existing site.
