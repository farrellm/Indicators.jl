# Regression Indicators

## Example

```@example
using Indicators, Plots, Random
Random.seed!(1)
x = 100 .+ cumsum(randn(252))

lookback = 20
reg = mlr_bands(x, n=lookback, mult=2.0)
coef = mlr_beta(x, n=lookback)
rsq = mlr_rsq(x, n=lookback)

f1 = plot(x, linewidth=3, color=:black, label="Price")
plot!([reg.lower reg.mid reg.upper], linewidth=1, label=["Lower" "MLR" "Upper"])
f2 = plot([coef.slope rsq], linewidth=2, color=[:purple :orange], label=["Slope" "R²"])
hline!([0.0, 1.0], linestyle=:dash, color=:grey, label="")
plot(f1, f2, layout=@layout[a{0.7h}; b{0.3h}])
savefig("reg_example.svg")  # hide
```
![](reg_example.svg)

## Reference

```@autodocs
Modules = [Indicators]
Pages = ["reg.jl"]
```
