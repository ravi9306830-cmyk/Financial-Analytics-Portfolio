## ============================================================
## 01_data_collection.R
## Portfolio Optimization & The Efficient Frontier
##
## Purpose : Pull daily adjusted price history for the chosen
##           asset universe from Yahoo Finance (via quantmod)
##           and save it locally so the rest of the pipeline is
##           reproducible offline.
## ============================================================

# install.packages(c("quantmod", "xts", "zoo"))
library(quantmod)
library(xts)
library(zoo)

# ---- 1. Define the asset universe -----------------------------------------
# A deliberately diversified basket: one Gold ETF (commodity hedge), one
# Nifty Midcap150 ETF (broad mid-cap equity), one Nasdaq-100 ETF (US / global
# equity exposure), and four individual large-caps spanning conglomerate,
# FMCG, banking and infrastructure — chosen so the correlation structure
# is genuinely interesting rather than five stocks that all move together.

tickers <- c(
  "GOLDBEES.NS",   # Gold ETF               - Commodity
  "ADANIENT.NS",   # Adani Enterprises      - Conglomerate / Energy
  "MID150BEES.NS", # Nifty Midcap150 ETF    - Diversified Mid-cap Equity
  "MON100.NS",     # Motilal Oswal Nasdaq100 ETF - US / Global Equity
  "NESTLEIND.NS",  # Nestle India           - FMCG
  "HDFCBANK.NS",   # HDFC Bank              - Banking / Financial Services
  "LT.NS"          # Larsen & Toubro        - Infrastructure / Engineering
)

start_date <- "2020-01-01"
end_date   <- Sys.Date()

# ---- 2. Download adjusted close prices ------------------------------------
getSymbols(tickers, src = "yahoo", from = start_date, to = end_date, auto.assign = TRUE)

# Merge each ticker's OHLCV series into a single wide xts object of
# adjusted close prices (this keeps corporate actions like splits/dividends
# consistent across the whole basket). quantmod::getSymbols() stores each
# series in the global environment under its exact ticker string.
price_list <- lapply(tickers, function(tk) Ad(get(tk)))
asset_prices <- do.call(merge, price_list)
colnames(asset_prices) <- gsub("\\.NS\\.Adjusted", "", colnames(asset_prices))

# Drop rows with any missing values (holidays / mismatched trading calendars)
asset_prices <- na.omit(asset_prices)

# ---- 3. Persist to disk so downstream scripts don't need the internet ----
dir.create("../data", showWarnings = FALSE)
write.csv(
  data.frame(Date = index(asset_prices), coredata(asset_prices)),
  "../data/asset_prices.csv",
  row.names = FALSE
)

cat("Downloaded", nrow(asset_prices), "trading days for", ncol(asset_prices), "assets\n")
cat("Range:", as.character(min(index(asset_prices))), "to", as.character(max(index(asset_prices))), "\n")
