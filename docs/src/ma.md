# Moving Averages

## Example

```@example
using Temporal, Indicators, Plots, Random
Random.seed!(1)
x = TS(100 .+ cumsum(randn(252)))
x.fields[1] = :Price

mafuns = [sma, ema, wma, trima]
m = hcat([f(x, n=40) for f in mafuns]...)

plot(x, linewidth=3, color=:black)
plot!(m, linewidth=2)
savefig("ma_example.svg")  # hide
```
![](ma_example.svg)


## Reference

```@autodocs
Modules = [Indicators]
Pages = ["ma.jl", "run.jl", "utils.jl"]
```
