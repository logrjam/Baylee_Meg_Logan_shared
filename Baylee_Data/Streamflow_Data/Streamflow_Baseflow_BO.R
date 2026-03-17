# ============================================================
# Download USGS daily Q → Save as <basin>/<SHORT_ID>_Q_25.csv
# Basins: Jordan / Bear / Weber
# Console prints: last 5 WY totals (mm) & Jan mean (mm/day), 5 decimals.
# ============================================================

# ---- Packages (install if needed) ----
req <- c("tidyverse", "lubridate", "dataRetrieval")
inst <- req[!req %in% rownames(installed.packages())]
if (length(inst)) install.packages(inst, repos = "https://cloud.r-project.org")
invisible(lapply(req, library, character.only = TRUE))

# ---- Where to save the basin folders ----
base_dir <- "/Users/bolds/Desktop/GSL data/2025 Streamflow Data from R"
dir.create(base_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(base_dir, "Jordan"), showWarnings = FALSE)
dir.create(file.path(base_dir, "Bear"),   showWarnings = FALSE)
dir.create(file.path(base_dir, "Weber"),  showWarnings = FALSE)

# ---- Areas (mm^2 → m^2) & Site list (with basin + short_id) ----
# short_id (e.g., W_WO, B_LBC, J_RB)
sites <- tribble(
  ~basin,  ~short_id, ~code,   ~site_no,   ~area_mm2,
  # Jordan
  "Jordan","J_CC",    "J_CC",  "10172500",  4.57e13,
  "Jordan","J_RB",    "J_RB",  "10172200",  1.87e13,
  "Jordan","J_EC",    "J_EC",  NA_character_, 4.75e13,   # fill site when ready
  "Jordan","J_PC",    "J_PC",  "10171500",  1.34e14,
  "Jordan","J_MC",    "J_MC",  "10170000",  5.62e13,
  "Jordan","J_BC",    "J_BC",  "10168500",  1.29e14,
  "Jordan","J_LC",    "J_LC",  "10167500",  7.07e13,
  # Bear
  "Bear",  "B_BCR",   "B_BCR", "10023000",  1.31e14,
  "Bear",  "B_SF",    "B_SF",  "10032000",  4.23e14,
  "Bear",  "B_BSF",   "B_BSF", "10113500",  6.80e14,
  "Bear",  "B_LR",    "B_LR",  "10109001",  5.54e14,
  "Bear",  "B_BRH",   "B_BRH", "10011500",  4.51e14,
  "Bear",  "B_LBC",   "B_LBC", "10104700",  1.61e14,
  # Weber
  "Weber", "W_WO",    "W_WO",  "10128500",  4.20e14,
  "Weber", "W_OSF",   "W_OSF", "10137500",  3.56e14,
  "Weber", "W_CC",    "W_CC",  "10131000",  6.44e14,
  "Weber", "W_EC",    "W_EC",  "10133800",  1.49e14,
  "Weber", "W_LC",    "W_LC",  "10132500",  3,25e14,
) %>%
  mutate(area_m2 = area_mm2 * 1e-6)

# ---- Helpers ----
wy_from_date <- function(d) lubridate::year(d + months(3))  # Oct–Dec → next WY
cfs_to_mm_day <- function(cfs, area_m2) {
  if (is.na(area_m2) || area_m2 <= 0) return(NA_real_)
  vol_m3 <- cfs * 0.028316846592 * 86400
  (vol_m3 / area_m2) * 1000
}
to_usgs_layout <- function(dv_raw) {
  dv_raw %>%
    dataRetrieval::addWaterYear() %>%
    mutate(Date = format(as.Date(Date), "%m/%d/%y")) %>%
    transmute(
      agency_cd,
      site_no,
      Date,
      waterYear,
      X_00060_00003,
      X_00060_00003_cd
    )
}

process_site <- function(basin, short_id, site_no, area_m2) {
  if (is.na(site_no)) {
    message("Skipping ", short_id, " (no site number).")
    return(invisible(NULL))
  }
  
  message("\nDownloading ", short_id, " (USGS ", site_no, ") …")
  dv <- dataRetrieval::readNWISdv(
    siteNumbers = site_no,
    parameterCd = "00060",
    stat        = "00003",
    startDate   = "1900-10-01",
    endDate     = as.character(Sys.Date())
  )
  if (nrow(dv) == 0) {
    warning("No data returned for site ", site_no)
    return(invisible(NULL))
  }
  
  # ---- Save daily in USGS layout ----
  out_daily <- to_usgs_layout(dv)
  out_dir   <- file.path(base_dir, basin)
  out_file  <- file.path(out_dir, paste0(short_id, "_Q_25.csv"))
  readr::write_csv(out_daily, out_file)
  message("Saved: ", out_file)
  
  # ---- Monthly means for baseflow  ----
  streamflow_data <- dv %>%
    mutate(
      Date  = as.Date(Date),
      Year  = year(Date),
      Month = month(Date, label = TRUE, abbr = TRUE)
    ) %>%
    dataRetrieval::addWaterYear() %>%
    rename(Water_Year = waterYear)
  
  monthly_streamflow <- streamflow_data %>%
    group_by(Water_Year, Year, Month) %>%
    summarize(Monthly_Streamflow_cfs = mean(X_00060_00003, na.rm = TRUE),
              .groups = "drop")
  
  # ---- January baseflow (mm/day) ----
  january_mean_streamflow <- monthly_streamflow %>%
    filter(Month == "Jan") %>%
    group_by(Water_Year) %>%
    summarize(January_Mean_Streamflow_cfs = mean(Monthly_Streamflow_cfs, na.rm = TRUE),
              .groups = "drop") %>%
    mutate(January_Mean_Streamflow_mm_day =
             cfs_to_mm_day(January_Mean_Streamflow_cfs, area_m2))
  
  jan_out <- file.path(out_dir, paste0(short_id, "_january_mean_streamflow_25.csv"))
  readr::write_csv(january_mean_streamflow, jan_out)
  message("Saved: ", jan_out)
  
  # ---- WY totals (mm/day equivalent) ----
  monthly_streamflow_sum <- streamflow_data %>%
    group_by(Water_Year, Year, Month) %>%
    summarize(Monthly_Streamflow_cfs = sum(X_00060_00003, na.rm = TRUE),
              .groups = "drop")
  
  complete_months <- c("Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep")
  
  water_year_streamflow <- monthly_streamflow_sum %>%
    filter(Month %in% complete_months) %>%
    group_by(Water_Year) %>%
    summarize(Water_Year_Streamflow_cfs =
                ifelse(all(complete_months %in% Month),
                       sum(Monthly_Streamflow_cfs, na.rm = TRUE),
                       NaN),
              .groups = "drop") %>%
    mutate(Water_Year_Streamflow_mm_day =
             cfs_to_mm_day(Water_Year_Streamflow_cfs, area_m2))
  
  wy_out <- file.path(out_dir, paste0(short_id, "_water_year_streamflow_25.csv"))
  readr::write_csv(water_year_streamflow, wy_out)
  message("Saved: ", wy_out)
  
  # ---- Console prints (5 decimals) ----
  wy_totals_mm <- dv %>%
    dataRetrieval::addWaterYear() %>%
    mutate(mm_day = cfs_to_mm_day(X_00060_00003, area_m2)) %>%
    group_by(waterYear) %>%
    summarize(total_mm = sum(mm_day, na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(waterYear)) %>% slice_head(n = 5) %>%
    mutate(total_mm = formatC(total_mm, format = "f", digits = 5)) %>%
    rename(Water_Year = waterYear)
  
  message("Last 5 WY TOTALS (mm) — ", short_id, ":")
  print(wy_totals_mm, n = nrow(wy_totals_mm))
  
  jan_print <- january_mean_streamflow %>%
    arrange(desc(Water_Year)) %>% slice_head(n = 5) %>%
    mutate(January_Mean_Streamflow_mm_day =
             formatC(January_Mean_Streamflow_mm_day, format = "f", digits = 5)) %>%
    select(Water_Year, January_Mean_Streamflow_mm_day)
  
  message("Last 5 WY BASEFLOW (January mean, mm/day) — ", short_id, ":")
  print(jan_print, n = nrow(jan_print))
}

# ---- Run (grouped into Jordan/Bear/Weber folders) ----
sites %>%
  arrange(match(basin, c("Jordan","Bear","Weber")), short_id) %>%
  pwalk(~process_site(..1, ..2, ..4, ..6))


