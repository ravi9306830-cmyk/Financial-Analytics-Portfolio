## ============================================================
## 05_optimal_portfolios.R
## Portfolio Optimization & The Efficient Frontier
##
## Purpose : Pull out the two portfolios that matter most from
##           the simulation, and print/save them as a clean
##           weights table — this is the actual "answer" the
##           whole exercise is trying to produce.
## ============================================================

portfolio_data <- read.csv("../data/simulated_portfolios.csv")
weight_cols <- grep("_Wt$", names(portfolio_data), value = TRUE)

max_sharpe <- portfolio_data[which.max(portfolio_data$SharpeRatio), ]
min_var    <- portfolio_data[which.min(portfolio_data$Risk), ]

summary_tbl <- data.frame(
  Portfolio = c("Maximum Sharpe Ratio", "Minimum Variance"),
  Return    = c(max_sharpe$Return, min_var$Return),
  Risk      = c(max_sharpe$Risk, min_var$Risk),
  Sharpe    = c(max_sharpe$SharpeRatio, min_var$SharpeRatio)
)

weights_tbl <- rbind(
  `Maximum Sharpe Ratio` = as.numeric(max_sharpe[weight_cols]),
  `Minimum Variance`     = as.numeric(min_var[weight_cols])
)
colnames(weights_tbl) <- gsub("_Wt$", "", weight_cols)

cat("=== Portfolio Summary ===\n")
print(summary_tbl, row.names = FALSE)
cat("\n=== Asset Weights (%) ===\n")
print(weights_tbl)

write.csv(summary_tbl, "../data/optimal_portfolio_summary.csv", row.names = FALSE)
write.csv(weights_tbl, "../data/optimal_portfolio_weights.csv")
