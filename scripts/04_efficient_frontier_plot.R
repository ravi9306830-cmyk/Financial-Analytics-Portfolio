## ============================================================
## 04_efficient_frontier_plot.R
## Portfolio Optimization & The Efficient Frontier
##
## Purpose : Visualize the simulated portfolios as a risk/return
##           scatter, color-coded by Sharpe Ratio, and mark the
##           two portfolios an investor actually cares about:
##             - Maximum Sharpe Ratio portfolio (best risk-adjusted return)
##             - Minimum Variance portfolio (lowest possible risk)
## ============================================================

library(ggplot2)
library(scales)

portfolio_data <- read.csv("../data/simulated_portfolios.csv")

max_sharpe_pt <- portfolio_data[which.max(portfolio_data$SharpeRatio), ]
min_var_pt    <- portfolio_data[which.min(portfolio_data$Risk), ]

p <- ggplot(portfolio_data, aes(x = Risk, y = Return, color = SharpeRatio)) +
  geom_point(size = 2, alpha = 0.75) +
  scale_color_gradientn(colors = c("#3B4CC0", "#F7C331", "#B40426"),
                         name = "Sharpe\nRatio") +
  geom_point(data = max_sharpe_pt, aes(x = Risk, y = Return),
             color = "black", fill = "gold", shape = 23, size = 5, stroke = 1.1) +
  geom_point(data = min_var_pt, aes(x = Risk, y = Return),
             color = "black", fill = "springgreen3", shape = 23, size = 5, stroke = 1.1) +
  annotate("text", x = max_sharpe_pt$Risk, y = max_sharpe_pt$Return,
           label = "  Max Sharpe", hjust = 0, vjust = -0.9, size = 3.6, fontface = "bold") +
  annotate("text", x = min_var_pt$Risk, y = min_var_pt$Return,
           label = "  Min Variance", hjust = 0, vjust = 1.6, size = 3.6, fontface = "bold") +
  scale_x_continuous(labels = percent_format(accuracy = 1)) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    title    = "Efficient Frontier \u2014 1,000 Simulated Portfolios",
    subtitle = "7-asset universe: Gold ETF, Adani Enterprises, Nifty Midcap150 ETF,\nNasdaq100 ETF, Nestle India, HDFC Bank, L&T",
    x = "Annualized Risk (Std. Deviation)",
    y = "Annualized Expected Return"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 15),
    plot.subtitle = element_text(color = "grey35", size = 10),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

dir.create("../plots", showWarnings = FALSE)
ggsave("../plots/efficient_frontier.png", plot = p, width = 9, height = 6, dpi = 160)

cat("Plot saved to ../plots/efficient_frontier.png\n")
