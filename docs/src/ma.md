# Moving Averages

## Example

```@example
using Indicators, Plots, Random
Random.seed!(1)
x = 100 .+ cumsum(randn(252))

mafuns = [sma, ema, wma, trima]
m = hcat([f(x, n=40) for f in mafuns]...)

plot(x, linewidth=3, color=:black, label="Price")
plot!(m, linewidth=2, label=permutedims(uppercase.(string.(mafuns))))
savefig("ma_example.svg")  # hide
```
![](ma_example.svg)


## Reference

```@autodocs
Modules = [Indicators]
Pages = ["ma.jl", "run.jl", "utils.jl"]
```
