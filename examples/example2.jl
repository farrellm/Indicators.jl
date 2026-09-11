using Indicators
using PyPlot
using Dates
using Random

# Synthetic daily OHLC data for one trading year
Random.seed!(2)
n = 252
t = collect(Date(2015, 1, 2):Day(1):(Date(2015, 1, 2)+Day(n-1)))
Close = 100.0 .+ cumsum(randn(n))
Open = [Close[1]; Close[1:(end-1)]]
High = max.(Open, Close) .+ rand(n)
Low = min.(Open, Close) .- rand(n)
HLC = [High Low Close]

subplot(411)
plot(t, Close, lw = 2, c = "k", label = "Price")
plot(t, kama(Close), c = "b", label = "Kaufman AMA")
plot(t, trima(Close), c = "g", label = "Triangula MA")
plot(t, hma(Close), c = "r", label = "Hull MA")
grid(ls = "-", c = [0.8, 0.8, 0.8])
legend(loc = "best", frameon = false)

subplot(412)
plot(t, kst(Close), c = "m", label = "KST")
plot(t, sma(kst(Close), n = 9), c = "c", label = "Signal")
plot([t[1], t[end]], [0, 0], ls = "--", c = [0.4, 0.4, 0.4])
grid(ls = "-", c = [0.8, 0.8, 0.8])
legend(loc = "best", frameon = false)

subplot(413)
plot(t, wpr(HLC), c = [1, 0.5, 0], label = "Williams %R")
plot([t[1], t[end]], [-20, -20], c = "r", ls = "--")
plot([t[1], t[end]], [-80, -80], c = "g", ls = "--")
grid(ls = "-", c = [0.8, 0.8, 0.8])
legend(loc = "best", frameon = false)

subplot(414)
plot(t, cci(HLC), c = "c", label = "CCI")
plot([t[1], t[end]], [-100, -100], c = "g", ls = "--")
plot([t[1], t[end]], [100, 100], c = "r", ls = "--")
grid(ls = "-", c = [0.8, 0.8, 0.8])
legend(loc = "best", frameon = false)

tight_layout()
