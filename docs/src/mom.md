# Momentum Indicators

## Example

```@example
using Indicators, Plots, Random
Random.seed!(1)
N = 252
c = 100 .+ cumsum(randn(N))
o = [c[1]; c[1:end-1]]
h = max.(o, c) .+ abs.(randn(N))
l = min.(o, c) .- abs.(randn(N))

m = macd(c)
r = rsi(c)
p = psar([h l])

f1 = plot(c, linewidth=3, color=:black, label="Close")
scatter!(p, color=:blue, markersize=2, label="PSAR")
f2 = plot(m, linewidth=2, color=[:green :cyan :orange], label=["MACD" "Signal" "Histogram"])
hline!([0.0], linestyle=:dash, color=:grey, label="")
f3 = plot(r, linewidth=2, color=:gold, label="RSI")
hline!([20, 80], linestyle=:dot, color=[:green, :red], label="")
plot(f1, f2, f3, layout=@layout[a{0.6h}; b{0.2h}; c{0.2h}])
savefig("mom_example.svg")  # hide
```
![](mom_example.svg)

## Reference

```@autodocs
Modules = [Indicators]
Pages = ["mom.jl"]
```
