# Regression Indicators

## Example

```@example
using Indicators, Plots, Random
Random.seed!(1)
x = 100 .+ cumsum(randn(252))

lookback = 20
n_sigma = 2.0
reg = mlr_bands(x, n=lookback, se=n_sigma)
coef = mlr_beta(x, n=lookback)
rsq = mlr_rsq(x, n=lookback)

f1 = plot(x, linewidth=3, color=:black, label="Price")
plot!(reg, linewidth=1, label=["Lower" "MLR" "Upper"])
f2 = plot([coef[:, 2] rsq], linewidth=2, color=[:purple :orange], label=["Slope" "R²"])
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
