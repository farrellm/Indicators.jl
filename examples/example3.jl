using Indicators
using PyPlot
using Random

# Synthetic daily prices
Random.seed!(3)
n = 200
t = 1:n
x = 400.0 .+ cumsum(randn(n))

plot(t, x, label = "Price", lw = 3, color = "blue")
grid(true, ls = "-", color = "black", alpha = 0.25)

# First-, second- and third-order trendlines
for order in 1:3
    maxi = maxima(x, order = order)
    mini = minima(x, order = order)
    plot(t[maxi], x[maxi], label = order == 1 ? "Resistance" : nothing, color = "red",
        marker = "o")
    plot(t[mini], x[mini], label = order == 1 ? "Support" : nothing, color = "green",
        marker = "o")
end

legend(loc = "best", frameon = false)

tight_layout()
