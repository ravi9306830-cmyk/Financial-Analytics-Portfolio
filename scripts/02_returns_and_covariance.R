## ============================================================
## 02_returns_and_covariance.R
## Portfolio Optimization & The Efficient Frontier
##
## Purpose : Turn the raw price series into the three building
##           blocks every mean-variance model needs:
##             (a) daily log returns
##             (b) expected (annualized) return per asset
##             (c) the annualized variance-covariance matrix
## ============================================================

library(xts)
library(zoo)

asset_prices_df <- read.csv("../data/asset_prices.csv")
asset_prices <- xts(asset_prices_df[, -1], order.by = as.Date(asset_prices_df$Date))

# ---- 1. Daily log returns --------------------------------------------------
# Log returns are used (rather than simple returns) because they are
# time-additive: the log return over 5 days is just the sum of the 5 daily
# log returns, which makes the annualization step below mathematically clean.
daily_returns <- diff(log(asset_prices))
daily_returns <- na.omit(daily_returns)

# ---- 2. Expected return per asset -----------------------------------------
mean_returns  <- colMeans(daily_returns)          # daily mean
annual_return <- mean_returns * 252               # ~252 trading days/year

# ---- 3. Variance-covariance matrix -----------------------------------------
cov_matrix        <- cov(daily_returns)           # daily covariance
annual_cov_matrix <- cov_matrix * 252             # annualized covariance

# ---- 4. Risk-free rate ------------------------------------------------------
# Used later for the Sharpe Ratio. 6% approximates the prevailing Indian
# 10-year G-Sec yield used as the risk-free proxy.
risk_free_rate <- 0.06

cat("Annualized Return by asset:\n");        print(round(annual_return, 4))
cat("\nAnnualized volatility (sd) by asset:\n")
print(round(sqrt(diag(annual_cov_matrix)), 4))

saveRDS(list(daily_returns = daily_returns, mean_returns = mean_returns,
             annual_return = annual_return, cov_matrix = cov_matrix,
             annual_cov_matrix = annual_cov_matrix, risk_free_rate = risk_free_rate),
        "../data/returns_and_covariance.rds")
