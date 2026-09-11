using Indicators, GLMakie, Random

# Synthetic daily prices for one trading year
Random.seed!(4)
N = 252
x = 1300.0 .+ cumsum(randn(N))

lookback = 20
reg = mlr_bands(x, n = lookback, mult = 2.0)
coef = mlr_beta(x, n = lookback)
rsq = mlr_rsq(x, n = lookback)

fig = Figure()
fig[1, 1] = Axis(fig, title = "Synthetic Prices")
lines!(fig[1, 1], x, label = "Price (Observed)", linewidth = 3, color = :black)
lines!(fig[1, 1], reg.mid, label = "Predicted", linewidth = 1, color = :blue)
lines!(fig[1, 1], reg.lower, label = "-2 Std Err", linewidth = 1, color = :red)
lines!(fig[1, 1], reg.upper, label = "+2 Std Err", linewidth = 1, color = :green)
band!(1:N, reg.lower, reg.upper, color = "#80800040")
axislegend(
    bgcolor = "#00000040",
    framecolor = "#00000040",
    position = :cb,
    orientation = :horizontal,
)
lines(fig[2, 1], 1:N, coef.slope, label = "Beta", linewidth = 2, color = :purple)
lines!(fig[2, 1], 1:N, rsq, label = "R-Squared", linewidth = 2, color = "#FF8000")
band!(1:N, zeros(N), rsq, color = "#FF800040")
hlines!(current_axis(), [0.0, 1.0], linestyle = :dash, linewidth = 1)
axislegend(
    bgcolor = "#00000040",
    framecolor = "#00000040",
    position = :cb,
    orientation = :horizontal,
)
