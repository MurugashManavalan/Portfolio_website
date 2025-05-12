library(exifr)
library(glue)
library(tidyverse)
library(lubridate)

# Define base paths
image_dir <- "/Users/murugash/Documents/Portfolio Website/Photography Portfolio/Nature"
output_base <- "/Users/murugash/Documents/Portfolio Website/qmds/Nature"

# Get all image files
lsfiles <- file.info(dir(image_dir, full.names = TRUE, recursive = TRUE))
lsfiles <- lsfiles[order(lsfiles$mtime, decreasing = TRUE),]
files <- rownames(lsfiles)

# Read EXIF metadata
dat <- read_exif(files)

# Loop through each image
for (i in seq_along(files)) {
  # Extract and format metadata
  title <- stringr::str_to_title(dat[i, ]$FileName)
  title <- str_split(title, "\\.")[[1]][1]
  image_location <- dat[i, ]$SourceFile
  date <- as_datetime(dat[i, ]$FileModifyDate)
  description <- "A nature photograph by Murugash."

  # File name for QMD
  file_name <- paste0(gsub(" ", "_", title), ".qmd")

  # Create output directory if needed
  if (!dir.exists(output_base)) dir.create(output_base, recursive = TRUE)

  # Write the .qmd file only if it doesn't exist
  output_path <- file.path(output_base, file_name)
  if (!file.exists(output_path)) {
    glue("
---
title: <<title>>
author: Murugash
image: ../../Photography Portfolio/Nature/<<basename(image_location)>>
description: <<description>>
categories: [Nature]
date: <<date>>
format:
  html:
    page-layout: full
---

![](../../Photography Portfolio/Nature/<<basename(image_location)>>)
    ", .open = "<<", .close = ">>") %>%
      write_lines(output_path)
  }
}
