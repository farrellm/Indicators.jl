# Indicators.jl

[Indicators](https://github.com/farrellm/Indicators.jl) is a Julia package offering efficient implementations of many technical analysis indicators and algorithms. This work is inspired by the [TTR](https://github.com/joshuaulrich/TTR) package in R and the Python implementation of [TA-Lib](https://mrjbq7.github.io/ta-lib/), and the ultimate goal is to implement all of the functionality of these offerings (and more) in Julia. The indicators take plain Julia vectors and, optionally, any [Tables.jl](tables.md) table. Contributions are of course always welcome for wrapping any of these functions in methods for other types and/or packages out there, as are suggestions for other indicators to add to the lists below.

## Usage

```julia
using Indicators

c = 100 .+ cumsum(randn(252))
h = c .+ 1
l = c .- 1

sma(c; n = 20)             # Vector{Float64}
atr(h, l, c; n = 14)       # one vector per series
bb = bbands(c; n = 20)     # NamedTuple (lower, mid, upper)
bb.upper
```

Indicators that need several series take one vector per series, in the order open, high,
low, close, volume. Indicators with several outputs return a `NamedTuple` of vectors.
Every indicator also accepts a table, such as a `DataFrame`; see [Tables](tables.md).

## Migrating from 0.8

Version 0.9 replaced Temporal.jl support with Tables.jl support and redesigned the array
API:

| 0.8 | 0.9 |
|:--- |:--- |
| `sma(ts)` with a Temporal.jl `TS` | `sma(tbl)` with any Tables.jl table |
| `atr([h l c])`, `psar([h l])`, `vwma([c v])` | `atr(h, l, c)`, `psar(h, l)`, `vwma(c, v)` |
| `heikinashi([o h l c])` | `heikinashi(o, h, l, c)` |
| `macd(x)[:, 1]` | `macd(x).macd` |
| `bbands(x; sigma = 2)`, `mlr_bands(x; se = 2)` | `bbands(x; mult = 2)`, `mlr_bands(x; mult = 2)` |
| `stoch(...; nK = 14, nD = 3)` | `stoch(...; nk = 14, nd = 3)` |
| `smi(...; nFast, nSlow, nSig, maFast, maSlow, maSig)` | `smi(...; nfast, nslow, nsig, fast_ma, slow_ma, signal_ma)` |
| `macd(x; fastMA, slowMA, signalMA)` | `macd(x; fast_ma, slow_ma, signal_ma)` |
| `kama(x; nfast = 0.6667, nslow = 0.0645)` (smoothing constants) | `kama(x; nfast = 2, nslow = 30)` (periods) |
| `runmean(X::Matrix)` and other per-column matrix methods | `map(runmean, eachcol(X))` |
| `mode(x)` | `StatsBase.mode(x)` |

Output keys of the multi-output indicators:

| Indicator | Keys |
|:--- |:--- |
| `bbands`, `keltner`, `donch`, `mlr_bands` | `lower`, `mid`, `upper` |
| `macd` | `macd`, `signal`, `histogram` |
| `adx` | `di_plus`, `di_minus`, `adx` |
| `aroon` | `up`, `down`, `osc` |
| `stoch` | `k`, `d` |
| `smi` | `smi`, `signal` |
| `mama` | `mama`, `fama` |
| `mlr_beta` | `intercept`, `slope` |
| `ichimoku` | `tenkan`, `kijun`, `senkou_a`, `senkou_b`, `chikou` |
| `heikinashi` | `open`, `high`, `low`, `close` |

Some results also change because of bug fixes: `aroon` (the up/down lines were
inverted and scaled by a fixed 25), `alma` (it returned a lagged price instead of a
weighted average), and `ichimoku`'s default Tenkan period (now 9, the standard).
