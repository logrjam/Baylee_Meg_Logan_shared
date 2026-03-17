# ============================================================
# PRISM Monthly TMEAN Extraction (COG + Legacy) — 3 Basins
# Basins: Weber (CC, OSF, WO, Wheeler), Jordan (BC, CC, EC, LC, MC, PC, RB),
#         Bear (BCR, BRH, BSF, LBC, LR, SF)
# Author: Baylee Olds — (11/03/2025)
# ============================================================

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
  library(lubridate)
})

# ---- Directories (EDIT if needed) ----
base_out_dir   <- "/Users/bolds/Desktop/Melt_Data"
prism_dir      <- "/Users/bolds/Desktop/GSL data/PRISM data/Temp"  # same folder you keep PRISM monthly

WeberShapeFiles  <- "/Users/bolds/Desktop/Melt_Data/Shapefiles/WeberShapeFiles"
JordanShapeFiles <- "/Users/bolds/Desktop/Melt_Data/Shapefiles/JordanShapeFiles"
BearShapeFiles   <- "/Users/bolds/Desktop/Melt_Data/Shapefiles/BearShapeFiles"

# If PRISM tmean is stored elsewhere, point prism_dir there.

# ---- Optional scale factor for PRISM tmean (set to 0.1 or 0.01 if needed) ----
SCALE_TMEAN <- 1.0

# ---- Basin configs (catchments in desired column order) ----
BASINS <- list(
  list(
    name = "Weber",
    shape_dir = WeberShapeFiles,
    catchment_order = c("CC", "EC", "LC", "OSF","WO")
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
# Helpers (shared with precip script, tweaked for tmean)
# ============================================================

find_catchment_paths <- function(shape_dir, wanted) {
  sub_dirs <- list.dirs(shape_dir, full.names = TRUE, recursive = FALSE)
  paths <- list()
  for (d in sub_dirs) {
    cand1 <- file.path(d, "globalwatershed.shp")
    cand2 <- file.path(d, "Wheeler.shp")
    shp <- NA_character_
    if (file.exists(cand1)) shp <- cand1
    if (is.na(shp) && file.exists(cand2)) shp <- cand2
    if (is.na(shp)) {
      anyshp <- list.files(d, pattern = "\\.shp$", full.names = TRUE)
      if (length(anyshp) == 1) shp <- anyshp
    }
    if (!is.na(shp)) paths[[basename(d)]] <- shp
  }
  has <- intersect(wanted, names(paths))
  if (length(has) < length(wanted)) {
    missing <- setdiff(wanted, has)
    stop("Missing shapefiles for: ", paste(missing, collapse = ", "),
         "\nLooked under: ", shape_dir)
  }
  paths[wanted]
}

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

# Discover PRISM monthly *tmean* files (COG + legacy) and parse YYYYMM
discover_prism_tmean_files <- function(prism_dir) {
  # New-ish flat filenames can vary:
  #  - prism_tmean_us_4km_YYYYMM.tif
  #  - prism_tmean_us_25m_YYYYMM.tif or .bil
  #  - Some users have "prism_tmean_us_25mm_YYYYMM.bil" (typo variant); accept it.
  files_flat <- list.files(
    prism_dir,
    pattern = "(?i)prism_tmean_us_.*_(\\d{6})\\.(tif|bil)$",
    full.names = TRUE, recursive = FALSE
  )
  # legacy tree:
  files_deep <- list.files(
    prism_dir,
    pattern = "(?i)PRISM_tmean_stable_4kmM[23]_\\d{6}_bil\\.bil$",
    full.names = TRUE, recursive = TRUE
  )
  allf <- unique(c(files_flat, files_deep))
  if (!length(allf)) {
    stop("No PRISM monthly tmean files found in: ", prism_dir,
         "\nExpected e.g. prism_tmean_us_4km_YYYYMM.tif (COG) or legacy *_bil.bil")
  }
  ym <- str_match(basename(allf), "(\\d{6})")[,2]
  df <- data.frame(file = allf, ym = ym, stringsAsFactors = FALSE)
  df <- df[!is.na(df$ym), , drop = FALSE]
  df$year  <- as.integer(substr(df$ym, 1, 4))
  df$month <- as.integer(substr(df$ym, 5, 6))
  df <- df |>
    filter(year >= 1900, year <= 2025, month >= 1, month <= 12) |>
    arrange(year, month)
  if (!nrow(df)) stop("Found tmean files, but none with valid YYYYMM.")
  df
}

# Extract area-weighted monthly mean temperature (apply SCALE_TMEAN)
extract_monthlies_tmean <- function(basin_sf, catchment_order, tmean_meta) {
  monthly_results <- tidyr::expand_grid(
    year = sort(unique(tmean_meta$year)),
    month = 1:12,
    CatchmentName = catchment_order
  )
  monthly_results$T_C <- NA_real_
  
  for (i in seq_len(nrow(tmean_meta))) {
    f  <- tmean_meta$file[i]
    yr <- tmean_meta$year[i]
    mo <- tmean_meta$month[i]
    message(sprintf("[%04d-%02d] %s", yr, mo, basename(f)))
    
    r_spat <- tryCatch(terra::rast(f), error = function(e) NULL)
    if (is.null(r_spat)) { warning("Skipping unreadable: ", f); next }
    r_ras  <- raster::raster(r_spat)
    
    basin_rp <- sf::st_transform(basin_sf, crs = terra::crs(r_spat))
    
    vals <- exactextractr::exact_extract(r_ras, basin_rp, fun = "weighted_mean", weights = "area")
    
    for (j in seq_along(catchment_order)) {
      monthly_results$T_C[
        monthly_results$year == yr &
          monthly_results$month == mo &
          monthly_results$CatchmentName == catchment_order[j]
      ] <- vals[j] * SCALE_TMEAN
    }
  }
  monthly_results
}

# Day-weighted water-year mean temperature (Oct–Sep)
calc_wy_tmean <- function(monthly_df, wy_start = 1901, wy_end = 2025) {
  out <- data.frame(WY = integer(), CatchmentName = character(), T_WY_C = numeric())
  
  # helper: return days in a given (year, month)
  dim_fun <- function(y, m) days_in_month(make_date(y, m, 1)) |> as.integer()
  
  for (wy in wy_start:wy_end) {
    # months in WY: Oct(wy-1)–Dec(wy-1), Jan–Sep(wy)
    prev <- monthly_df |> filter(year == (wy - 1), month %in% 10:12)
    curr <- monthly_df |> filter(year == wy,       month %in% 1:9)
    combined <- bind_rows(prev, curr)
    
    if (!nrow(combined)) next
    
    combined <- combined |>
      mutate(days = mapply(dim_fun, year, month))
    
    wy_stats <- combined |>
      group_by(CatchmentName) |>
      summarise(
        T_WY_C = weighted.mean(T_C, w = days, na.rm = TRUE),
        .groups = "drop"
      ) |>
      mutate(WY = wy)
    
    out <- bind_rows(out, wy_stats)
  }
  out
}

plot_basin_map <- function(sfobj, basin_name) {
  ggplot(st_transform(sfobj, 5070)) +
    geom_sf(fill = "lightblue", color = "darkblue") +
    geom_sf_text(aes(label = CatchmentName), size = 3) +
    theme_minimal() +
    labs(title = paste0(basin_name, " Catchments (tmean)"), caption = "Local shapefiles")
}

# ============================================================
# Main driver for one basin (tmean)
# ============================================================
run_basin_tmean <- function(name, shape_dir, catchment_order) {
  cat("\n========== ", name, " (tmean) ==========\n", sep="")
  
  basin_sf  <- load_catchments(shape_dir, catchment_order)
  print(plot_basin_map(basin_sf, name))
  
  tmean_meta <- discover_prism_tmean_files(prism_dir)
  
  monthly_results <- extract_monthlies_tmean(basin_sf, catchment_order, tmean_meta)
  
  wy_results <- calc_wy_tmean(monthly_results)
  
  # ---- Save wide CSVs ----
  monthly_wide <- monthly_results |>
    tidyr::pivot_wider(names_from = CatchmentName, values_from = T_C) |>
    dplyr::arrange(year, month) |>
    dplyr::select(dplyr::any_of(c("year", "month", catchment_order)))
  
  wy_wide <- wy_results |>
    tidyr::pivot_wider(names_from = CatchmentName, values_from = T_WY_C) |>
    dplyr::arrange(WY) |>
    dplyr::select(dplyr::any_of(c("WY", catchment_order)))
  
  out_monthly <- file.path(base_out_dir,
                           sprintf("PRISM_monthly_tmean_%s_1900_2025.csv", name))
  out_wy      <- file.path(base_out_dir,
                           sprintf("PRISM_annual_tmean_%s_WY1901_2025.csv", name))
  
  write.csv(monthly_wide, out_monthly, row.names = FALSE)
  write.csv(wy_wide,     out_wy,      row.names = FALSE)
  
  cat("✅ ", name, " Monthly tmean (wide) → ", out_monthly, "\n", sep = "")
  cat("✅ ", name, " WY tmean (day-weighted, wide) → ", out_wy, "\n", sep = "")
  
  invisible(list(monthly = monthly_wide, wy = wy_wide))
}

# ============================================================
# Run all three basins
# ============================================================
results_tmean <- lapply(BASINS, function(b)
  run_basin_tmean(name = b$name, shape_dir = b$shape_dir, catchment_order = b$catchment_order)
)

cat("\nAll basins complete (tmean).\n")
