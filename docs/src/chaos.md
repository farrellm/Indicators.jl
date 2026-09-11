# Chaos Theory / Fractals

# Example
```@example
using Indicators, Plots, Random
Random.seed!(1)
x = 100 .+ cumsum(randn(252))

r = [rsrange(x, n=60) rsrange(x, n=60, cumulative=true)]
h = [hurst(x, n=60) hurst(x, n=60, cumulative=true)]

f1 = plot(x, linewidth=3, color=:black, label="Price")
f2 = plot(r, linewidth=2, color=[:red :darkred], linestyle=[:solid :dash],
          label=["Rolling R/S" "Cumulative R/S"])
f3 = plot(h, linewidth=2, color=[:cyan :darkcyan], linestyle=[:solid :dash],
          label=["Rolling Hurst" "Cumulative Hurst"])
plot(f1, f2, f3, layout=@layout[a{0.5h}; b{0.25h}; c{0.25h}])
savefig("chaos_example.svg")  # hide
```
![](chaos_example.svg)

## Reference

```@autodocs
Modules = [Indicators]
Pages = ["chaos.jl"]
```
