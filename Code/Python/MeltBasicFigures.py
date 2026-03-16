# -*- coding: utf-8 -*-
"""
Created on Mon Mar 16 14:29:58 2026

@author: Logan.Jamison
"""

# melt_basic_figures.py
# Python rework of MeltBasicFigures.m (Logan Jamison)

# NOTE: missing allAugT and allNovT mat files. ok without Aug but need Nov

from pathlib import Path
import numpy as np
import statsmodels.api as sm
import matplotlib.pyplot as plt
from scipy.io import loadmat

# ---------- 1) Configure your local paths ----------
DATA_ROOT = Path(r"C:\USDA\Work\Code\GitHub\Baylee_Meg_Logan_shared\Data")

# Primary folder you provided (contains melt metrics, baseflow, streamflow, PET, etc.)
METRICS_DIR = DATA_ROOT / "LoganUpdatedMeltMetrics"

# OPTIONAL: If monthly climate files (allJanP.mat, allFebP.mat, ... allDecT.mat) exist at a different path,
# set SLC_WEBER_DIR to that location; otherwise comment out the climate-loading section below.
SLC_WEBER_DIR = DATA_ROOT / "SLCandWEBER"  # adjust if your monthly climate files reside elsewhere

YEARS = np.arange(1901, 2019)  # 118 years

# ---------- Helpers ----------
def mat_to_array(matdict, key_hint):
    """Extract array by key (fallback to first non-meta entry)."""
    for k in matdict:
        if not k.startswith("__"):
            if k.lower() == key_hint.lower():
                return np.array(matdict[k])
    for k in matdict:
        if not k.startswith("__"):
            return np.array(matdict[k])
    raise KeyError(f"Key {key_hint} not found in .mat file")

def mload(dirpath: Path, name: str):
    """Load a .mat file `name.mat` from `dirpath` and return its array."""
    return mat_to_array(loadmat(dirpath / f"{name}.mat"), name)

def zscore_nan(arr):
    mu  = np.nanmean(arr, axis=0)
    sig = np.nanstd(arr, axis=0, ddof=0)
    return (arr - mu) / sig

def ols_resid(y, X, add_const=True):
    if add_const:
        X = sm.add_constant(X, has_constant="add")
    model = sm.OLS(y, X, missing='drop')
    res = model.fit()
    return res.params, res.resid, res

# ---------- 2) Load melt metrics & hydro components (from your local folder) ----------
# These names mirror your MATLAB script in MeltBasicFigures_txt.txt
allmeltrate        = mload(METRICS_DIR, "allmeltrate")
meltratecp         = mload(METRICS_DIR, "meltratecp")
meltraterisingcp   = mload(METRICS_DIR, "meltraterisingcp")
meltratefallingcp  = mload(METRICS_DIR, "meltratefallingcp")
allmeltstart       = mload(METRICS_DIR, "allmeltstart")
meltstartcp        = mload(METRICS_DIR, "meltstartcp")
allbaseflow        = mload(METRICS_DIR, "allbaseflow")
allstreamflow      = mload(METRICS_DIR, "allstreamflow")  # q
allprecip          = mload(METRICS_DIR, "allprecip")      # p
alltemperature     = mload(METRICS_DIR, "alltemperature") # t
monthlymeanPET     = mload(METRICS_DIR, "monthlymeanPET")

q = allstreamflow
p = allprecip
t = alltemperature
wy = q / p

ncatch = meltratecp.shape[1]

# ---------- 3) (Optional) Load monthly climate and build derived aggregates ----------
# Your MATLAB script creates winter/spring aggregates from monthly files.
# If you have monthly files under SLC_WEBER_DIR, uncomment the section below.

def load_monthly_series(dirpath: Path, prefix: str):
    months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    series = []
    for m in months:
        name = f"all{m}{prefix}"
        filepath = dirpath / f"{name}.mat"

        if not filepath.exists():
            print(f"Missing file: {filepath.name}")
            series.append(None)
            continue

        series.append(mload(dirpath, name))

    return series


# Uncomment if available:
allP = load_monthly_series(SLC_WEBER_DIR, "P")  # precip (Jan..Dec)
allT = load_monthly_series(SLC_WEBER_DIR, "T")  # temp   (Jan..Dec)

# If monthly files are available, compute winter/spring aggregates exactly as in MATLAB:
winterp = allP[11] + allP[0] + allP[1]
springp = allP[2]  + allP[3] + allP[4]
snowP   = winterp + allP[2]
wintert = (allT[11] + allT[0] + allT[1]) / 3.0
springt = (allT[2]  + allT[3] + allT[4]) / 3.0
snowT   = (allT[11] + allT[0] + allT[1] + allT[2] + allT[3] + allT[4]) / 6.0

# If monthly files are NOT available, you can skip winter/spring derivations and proceed with the melt metrics.
# For completeness, the rest of the workflow assumes snowP/snowT exist; if not, comment any lines referencing them.

# ---------- 4) Normalize melt rate for winter precipitation (residuals) ----------
# Requires snowP. If you loaded monthly files and computed snowP, use them here.
# Example with a placeholder; replace with actual snowP when available:
# snowP = ...  # (years x catchments)

def resid_against_X(Y, X):
    resid = np.empty_like(Y)
    for i in range(ncatch):
        Xi = sm.add_constant(X[:, i], has_constant="add")
        res = sm.OLS(Y[:, i], Xi, missing='drop').fit()
        resid[:, i] = res.resid
    return resid

# nmrcp  = resid_against_X(meltratecp,        snowP)
# nmrrcp = resid_against_X(meltraterisingcp,  snowP)
# nmrfcp = resid_against_X(meltratefallingcp, snowP)

# ---------- 5) Z-scores & normalized (z) melt residuals ----------
zwy   = zscore_nan(wy)
zp    = zscore_nan(p)
zt    = zscore_nan(t)
zq    = (q - np.nanmean(q, axis=0)) / np.nanstd(q, axis=0)
zbf   = (allbaseflow - np.nanmean(allbaseflow, axis=0)) / np.nanstd(allbaseflow, axis=0)
zmrcp = (meltratecp - np.nanmean(meltratecp, axis=0)) / np.nanstd(meltratecp, axis=0)

# If snowP available:
# zsnowp = zscore_nan(snowP)
# znmrcp = resid_against_X(zmrcp, zsnowp)

# ---------- 6) Example figure (works without monthly inputs) ----------
def plot_time_series_mean(series_list, labels, years, ylabel, ylim=None, legend_loc="best"):
    plt.figure(figsize=(10, 5))
    for s, lab in zip(series_list, labels):
        plt.plot(years, np.nanmean(s, axis=1), label=lab, linewidth=2)
    plt.xlabel("Water Year")
    plt.ylabel(ylabel)
    if ylim: plt.ylim(*ylim)
    plt.legend(loc=legend_loc)
    plt.tight_layout()

# With melt metrics alone you can at least plot WY (z) time series:
plot_time_series_mean([zwy], ["Runoff Efficiency (z)"], YEARS, "z-score", ylim=(-3, 4))
plt.show()

# ---------- 7) WY ~ Storage + Normalized MR (z) ----------
# This block requires znmrcp (i.e., snowP). Uncomment when snowP is available.
# Bznwy2 = np.empty((3, ncatch))
# estnwy2 = np.empty_like(zwy)
# for i in range(ncatch):
#     X = np.column_stack([zbf[:, i], znmrcp[:, i]])
#     params, resid, res = ols_resid(zwy[:, i], X)
#     Bznwy2[:, i] = params
#     estnwy2[:, i] = res.predict()
# plot_time_series_mean([zwy, estnwy2], ["Runoff Efficiency", "Storage + Melt Rate (norm)"], YEARS, "z-score", ylim=(-3, 3), legend_loc="lower right")
# plt.show()
