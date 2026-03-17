# Download PRISM Precip data for Weber Catchments: CC, OSF, WO
# Baylee Olds 10/24/24 
# Based on Extract_PRISM_Jordan_precipitation.R by Logan Jamison_edited meg wolf

# Load necessary libraries
library(raster)
library(sf)
library(terra)
library(prism)
library(ggplot2)

# ============================================================
# Download PRISM Monthly Precipitation Data (NACSE API Method)
# PRISM DATA FORMAT UPDATE - OCTOBER 2025
# Author: Baylee Olds — 10/24/24
# Based on Extract_PRISM_Jordan_precipitation.R by L. Jamison (edited M. Wolf)
# ============================================================

# ---- Output Directory ----
prism_dir <- "/Users/bolds/Desktop/GSL data/PRISM data/Precip"
dir.create(prism_dir, recursive = TRUE, showWarnings = FALSE)
cat("Saving PRISM monthly data to:", normalizePath(prism_dir), "\n")

# ---- Helper Function ----
download_prism_month <- function(year, month, out_dir) {
  ym <- sprintf("%04d%02d", year, month)
  folder_name <- file.path(out_dir, paste0("PRISM_ppt_stable_4kmM3_", ym, "_bil"))
  # Skip if already exists
  if (dir.exists(folder_name)) {
    message("Already exists, skipping: ", folder_name)
    return(invisible(NULL))
  }
  # Construct NACSE API URL (explicitly request BIL format)
  url <- sprintf("https://services.nacse.org/prism/data/get/us/4km/ppt/%s?format=bil", ym)
  zip_file <- file.path(out_dir, paste0("PRISM_ppt_stable_4kmM3_", ym, "_bil.zip"))
  # Try download and unzip
  message("Downloading ", basename(zip_file), " ...")
  tryCatch({
    download.file(url, destfile = zip_file, mode = "wb", quiet = TRUE)
    utils::unzip(zip_file, exdir = out_dir)
    unlink(zip_file)
    message("✓ Downloaded and extracted: ", folder_name)
  }, error = function(e) {
    message("⚠️  Failed for ", ym, " → ", conditionMessage(e))
    if (file.exists(zip_file)) unlink(zip_file)
  })
  # Small pause to avoid rate limiting
  Sys.sleep(1)
}

# ---- Choose Year Range ----
years <- 1900:2025
months <- 1:12

# ---- Batch Download Loop ----
for (y in years) {
  for (m in months) {
    download_prism_month(y, m, prism_dir)
  }
}
cat("✅ All PRISM monthly precipitation downloads complete.\n")
cat("Data saved in:", normalizePath(prism_dir), "\n")

# Download PRISM Monthly Temperature Data (NACSE API Method)
# Variables: tmean (default), tmin, tmax
# Baylee Olds — 10/24/24 (adapted for temperature)

# ---- Output Directory ----
prism_dir <- "/Users/bolds/Desktop/GSL data/PRISM data/Temp"
dir.create(prism_dir, recursive = TRUE, showWarnings = FALSE)
cat("Saving PRISM monthly data to:", normalizePath(prism_dir), "\n")

# ---- Libraries ----
library(raster)
library(sf)
library(terra)
library(prism)
library(ggplot2)

# ---- Output Directory ----
prism_dir <- "/Users/bolds/Desktop/GSL data/PRISM data/Temp"
dir.create(prism_dir, recursive = TRUE, showWarnings = FALSE)
cat("Saving PRISM monthly data to:", normalizePath(prism_dir), "\n")

# ---- Choose Temperature Variable ----
# Options include: "tmean", "tmin", "tmax" (others exist, e.g., "tdmean")
prism_var <- "tmean"  # <- change to "tmin" or "tmax" if desired

# ---- Helper (Download one month) ----
download_prism_month_temp <- function(year, month, var, out_dir) {
  ym <- sprintf("%04d%02d", year, month)
  folder_name <- file.path(out_dir, paste0("PRISM_", var, "_stable_4kmM3_", ym, "_bil"))
  
  # Skip if already exists
  if (dir.exists(folder_name)) {
    message("Already exists, skipping: ", basename(folder_name))
    return(invisible(NULL))
  }
  
  # NACSE URL (explicitly request BIL, 4km, US region)
  url <- sprintf("https://services.nacse.org/prism/data/get/us/4km/%s/%s?format=bil", var, ym)
  zip_file <- file.path(out_dir, paste0("PRISM_", var, "_stable_4kmM3_", ym, "_bil.zip"))
  
  message("Downloading ", basename(zip_file), " ...")
  tryCatch({
    download.file(url, destfile = zip_file, mode = "wb", quiet = TRUE)
    utils::unzip(zip_file, exdir = out_dir)
    unlink(zip_file)
    message("✓ Downloaded and extracted: ", basename(folder_name))
  }, error = function(e) {
    message("⚠️  Failed for ", ym, " → ", conditionMessage(e))
    if (file.exists(zip_file)) unlink(zip_file)
  })
  
  Sys.sleep(1)  # small pause to avoid rate limiting
}

# ---- Year / Month Range ----
years  <- 1900:2025
months <- 1:12

# ---- Batch Download ----
for (y in years) {
  for (m in months) {
    download_prism_month_temp(y, m, prism_var, prism_dir)
  }
}
cat("✅ All PRISM monthly", prism_var, "downloads complete.\n")
cat("Data saved in:", normalizePath(prism_dir), "\n")
