## ============================================================
## 03_monte_carlo_simulation.R
## Portfolio Optimization & The Efficient Frontier
##
## Purpose : Randomly generate a large number of "long-only,
##           fully-invested" portfolios (weights are non-negative
##           and sum to 1), and compute the expected return, risk
##           and Sharpe Ratio for each one. Plotting all of them
##           traces out the feasible region and, along its upper
##           edge, the Efficient Frontier.
## ============================================================

set.seed(42)  # reproducibility

rc <- readRDS("../data/returns_and_covariance.rds")
annual_return     <- rc$annual_return
annual_cov_matrix <- rc$annual_cov_matrix
risk_free_rate    <- rc$risk_free_rate

nAssets        <- length(annual_return)
num_portfolios <- 1000

port_return <- numeric(num_portfolios)
port_risk   <- numeric(num_portfolios)
all_weights <- matrix(0, nrow = num_portfolios, ncol = nAssets)

for (i in 1:num_portfolios) {

  # Draw random weights, then normalize so they sum to 1 (Dirichlet-style
  # sampling). This is what makes the cloud of points below fill out the
  # entire feasible region evenly rather than clustering near equal-weight.
  w <- runif(nAssets)
  w <- w / sum(w)
  all_weights[i, ] <- w

  port_return[i] <- sum(w * annual_return)
  port_risk[i]   <- sqrt(as.numeric(t(w) %*% annual_cov_matrix %*% w))
}

sharpe_ratio <- (port_return - risk_free_rate) / port_risk

portfolio_data <- data.frame(
  Return      = port_return,
  Risk        = port_risk,
  SharpeRatio = sharpe_ratio,
  round(all_weights * 100, 1)
)
colnames(portfolio_data)[4:ncol(portfolio_data)] <- paste0(names(annual_return), "_Wt")

write.csv(portfolio_data, "../data/simulated_portfolios.csv", row.names = FALSE)

cat("Simulated", num_portfolios, "portfolios.\n")
cat("Return range:", round(range(port_return), 3), "\n")
cat("Risk range:  ", round(range(port_risk), 3), "\n")
