# ============================================================
# PRISM Monthly Precip Extraction (COG + Legacy) — 3 Basins
# Basins: Weber (CC, OSF, WO, Wheeler), Jordan (BC, CC, EC, LC, MC, PC, RB),
#         Bear (BCR, BRH, BSF, LBC, LR, SF)
# Author: Baylee Olds — (11/03/2025)
# ============================================================

# ---- Libraries ----
suppressPackageStartupMessages({
  library(sf)
  library(terra)
  library(exactextractr)
  library(ggplot2)
  library(dplyr)
  library(raster)   # exactextractr prefers RasterLayer
  library(tidyr)
  library(stringr)
  library(purrr)
})

# ---- Directories (EDIT if needed) ----
base_out_dir   <- "/Users/bolds/Desktop/Melt_Data"
prism_dir      <- "/Users/bolds/Desktop/GSL data/PRISM data/Precip"

WeberShapeFiles  <- "/Users/bolds/Desktop/Melt_Data/Shapefiles/WeberShapeFiles"
JordanShapeFiles <- "/Users/bolds/Desktop/Melt_Data/Shapefiles/JordanShapeFiles"
BearShapeFiles   <- "/Users/bolds/Desktop/Melt_Data/Shapefiles/BearShapeFiles"

# ---- Basin configs (catchments in desired column order) ----
BASINS <- list(
  list(
    name = "Weber",
    shape_dir = WeberShapeFiles,
    catchment_order = c("CC","EC", "LC", "OSF", "WO")
  ),
  list(
    name = "Jordan",
    shape_dir = JordanShapeFiles,
    catchment_order = c("BC", "CC", "EC", "LC", "MC", "PC", "RB")
  ),
  list(
    name = "Bear",
    shape_dir = BearShapeFiles,
    catchment_order = c("BCR", "BH", "BSF", "LBR", "LR", "SF")
  )
)

# ============================================================
# Helpers
# ============================================================

# Find catchment shapefiles in a basin folder.
#   Rule: each subfolder contains a polygon shapefile. Prefer "globalwatershed.shp",
#         but accept any single .shp if needed. Name is the subfolder name.
find_catchment_paths <- function(shape_dir, wanted) {
  sub_dirs <- list.dirs(shape_dir, full.names = TRUE, recursive = FALSE)
  paths <- list()
  for (d in sub_dirs) {
    cand1 <- file.path(d, "globalwatershed.shp")
    cand2 <- file.path(d, "Wheeler.shp") # special case used before
    shp <- NA_character_
    if (file.exists(cand1)) shp <- cand1
    if (is.na(shp) && file.exists(cand2)) shp <- cand2
    # fallback: any .shp in the folder
    if (is.na(shp)) {
      anyshp <- list.files(d, pattern = "\\.shp$", full.names = TRUE)
      if (length(anyshp) == 1) shp <- anyshp
    }
    if (!is.na(shp)) paths[[basename(d)]] <- shp
  }
  # keep only requested, in order
  has <- intersect(wanted, names(paths))
  if (length(has) < length(wanted)) {
    missing <- setdiff(wanted, has)
    stop("Missing shapefiles for: ", paste(missing, collapse = ", "),
         "\nLooked under: ", shape_dir)
  }
  paths[wanted]
}

# Load catchments and standardize to EPSG:4326; return sf with CatchmentName & Area_km2
load_catchments <- function(shape_dir, order_vec) {
  paths <- find_catchment_paths(shape_dir, order_vec)
  lst <- lapply(paths, function(p) {
    s <- st_read(p, quiet = TRUE)
    if (is.na(st_crs(s))) {
      message("⚠️  No CRS in ", basename(p), " — assuming WGS84 (EPSG:4326).")
      st_crs(s) <- 4326
    }
    st_transform(s, 4326) |> st_geometry()
  })
  sfobj <- st_as_sf(do.call(c, lst))
  sfobj$CatchmentName <- order_vec
  sfobj$Area_km2 <- as.numeric(st_area(st_transform(sfobj, 5070))) / 1e6
  sfobj
}

# Discover PRISM monthly precip files (COG + legacy) and parse YYYYMM
discover_prism_files <- function(prism_dir) {
  # Allow multiple patterns:
  #  - New (examples people see vary): "prism_ppt_us_4km_YYYYMM.tif", or "_25m_", or .bil COG
  #  - Legacy directory trees ending in "PRISM_ppt_stable_4kmM*_YYYYMM_bil.bil"
  files_flat <- list.files(prism_dir, pattern = "(?i)prism_ppt_us_.*_(\\d{6})\\.(tif|bil)$",
                           full.names = TRUE, recursive = FALSE)
  files_deep <- list.files(prism_dir,
                           pattern = "(?i)PRISM_ppt_stable_4kmM[23]_\\d{6}_bil\\.bil$",
                           full.names = TRUE, recursive = TRUE)
  allf <- unique(c(files_flat, files_deep))
  if (!length(allf)) {
    stop("No PRISM monthly precip files found in: ", prism_dir,
         "\nExpected e.g. prism_ppt_us_4km_YYYYMM.tif (COG) or legacy *_bil.bil")
  }
  ym <- str_match(basename(allf), "(\\d{6})")[,2]
  df <- data.frame(file = allf, ym = ym, stringsAsFactors = FALSE)
  df <- df[!is.na(df$ym), , drop = FALSE]
  df$year  <- as.integer(substr(df$ym, 1, 4))
  df$month <- as.integer(substr(df$ym, 5, 6))
  df <- df |>
    filter(year >= 1900, year <= 2025, month >= 1, month <= 12) |>
    arrange(year, month)
  if (!nrow(df)) stop("Found PRISM files, but none with valid YYYYMM.")
  df
}

# Water-year calculator: sums Oct(prev)–Sep(curr) per CatchmentName
calc_water_year <- function(df, wy_start = 1901, wy_end = 2025) {
  out <- data.frame(WY = integer(), CatchmentName = character(), P_WY_mm = numeric())
  for (wy in wy_start:wy_end) {
    prev <- dplyr::filter(df, year == (wy - 1), month %in% 10:12)
    curr <- dplyr::filter(df, year == wy,       month %in% 1:9)
    combined <- dplyr::bind_rows(prev, curr)
    if (nrow(combined)) {
      out <- rbind(
        out,
        combined |>
          dplyr::group_by(CatchmentName) |>
          dplyr::summarise(P_WY_mm = sum(P_mm, na.rm = TRUE), .groups = "drop") |>
          dplyr::mutate(WY = wy)
      )
    }
  }
  out
}

# Extract area-weighted monthly means for a basin
extract_monthlies <- function(basin_sf, catchment_order, ppt_meta) {
  monthly_results <- tidyr::expand_grid(
    year = sort(unique(ppt_meta$year)),
    month = 1:12,
    CatchmentName = catchment_order
  )
  monthly_results$P_mm <- NA_real_
  
  # iterate available rasters
  for (i in seq_len(nrow(ppt_meta))) {
    f  <- ppt_meta$file[i]
    yr <- ppt_meta$year[i]
    mo <- ppt_meta$month[i]
    message(sprintf("[%04d-%02d] %s", yr, mo, basename(f)))
    
    r_spat <- tryCatch(terra::rast(f), error = function(e) NULL)
    if (is.null(r_spat)) { warning("Skipping unreadable: ", f); next }
    r_ras  <- raster::raster(r_spat)
    
    # reproject polygons to raster CRS
    basin_rp <- sf::st_transform(basin_sf, crs = terra::crs(r_spat))
    
    # area-weighted mean per polygon
    vals <- exactextractr::exact_extract(r_ras, basin_rp, fun = "weighted_mean", weights = "area")
    
    # write
    for (j in seq_along(catchment_order)) {
      monthly_results$P_mm[
        monthly_results$year == yr &
          monthly_results$month == mo &
          monthly_results$CatchmentName == catchment_order[j]
      ] <- vals[j]
    }
  }
  monthly_results
}

# Small QA plot
plot_basin_map <- function(sfobj, basin_name) {
  ggplot(st_transform(sfobj, 5070)) +
    geom_sf(fill = "lightblue", color = "darkblue") +
    geom_sf_text(aes(label = CatchmentName), size = 3) +
    theme_minimal() +
    labs(title = paste0(basin_name, " Catchments"), caption = "Local shapefiles")
}

# ============================================================
# Main driver for one basin
# ============================================================
run_basin <- function(name, shape_dir, catchment_order) {
  cat("\n========== ", name, " ==========\n", sep="")
  # 1) Load catchments
  basin_sf <- load_catchments(shape_dir, catchment_order)
  print(plot_basin_map(basin_sf, name))
  
  # 2) Discover PRISM files
  ppt_meta <- discover_prism_files(prism_dir)
  
  # 3) Extract monthlies
  monthly_results <- extract_monthlies(basin_sf, catchment_order, ppt_meta)
  
  # 4) WY totals
  annual_results <- calc_water_year(monthly_results)
  
  # 5) Save wide CSVs (same naming pattern you used for Weber)
  monthly_wide <- monthly_results |>
    tidyr::pivot_wider(names_from = CatchmentName, values_from = P_mm) |>
    dplyr::arrange(year, month) |>
    dplyr::select(dplyr::any_of(c("year", "month", catchment_order)))
  
  annual_wide <- annual_results |>
    tidyr::pivot_wider(names_from = CatchmentName, values_from = P_WY_mm) |>
    dplyr::arrange(WY) |>
    dplyr::select(dplyr::any_of(c("WY", catchment_order)))
  
  out_monthly <- file.path(base_out_dir,
                           sprintf("PRISM_monthly_precip_%s_1900_2025.csv", name))
  out_annual  <- file.path(base_out_dir,
                           sprintf("PRISM_annual_precip_%s_WY1901_2025.csv", name))
  
  write.csv(monthly_wide, out_monthly, row.names = FALSE)
  write.csv(annual_wide,  out_annual,  row.names = FALSE)
  
  cat("✅ ", name, " Monthly (wide) → ", out_monthly, "\n", sep = "")
  cat("✅ ", name, " Annual  (WY)   → ", out_annual,  "\n", sep = "")
  
  invisible(list(monthly = monthly_wide, annual = annual_wide))
}

# ============================================================
# Run all three basins
# ============================================================
results <- lapply(BASINS, function(b)
  run_basin(name = b$name, shape_dir = b$shape_dir, catchment_order = b$catchment_order)
)

cat("\nAll basins complete.\n")