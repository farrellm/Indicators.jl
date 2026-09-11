# Tables

Every indicator also accepts a table in place of its price vectors: any
[Tables.jl](https://github.com/JuliaData/Tables.jl) source, such as a `DataFrame`, a
`CSV.File`, a TimeSeries.jl `TimeArray` or a `NamedTuple` of vectors.

Table support lives in a package extension that loads automatically once Tables.jl is
loaded, which `using DataFrames`, `using CSV` or `using TimeSeries` all do. `using
Indicators` on its own never loads Tables.jl.

```@example tables
using Indicators, DataFrames, Dates, Random
Random.seed!(1)
N = 60
c = 100 .+ cumsum(randn(N))
df = DataFrame(
    Date = Date(2024, 1, 2) .+ Day.(0:(N-1)),
    Open = c .+ randn(N) ./ 2,
    High = c .+ 1,
    Low = c .- 1,
    Close = c,
    Volume = rand(1000:5000, N),
)
last(bbands(df; n = 20), 3)
```

```@example tables
last(atr(df), 3)
```

## Columns

Each indicator reads the columns it needs by name: `open`, `high`, `low`, `close` and
`volume`, matched exactly but ignoring case. There is no substring matching, and an
adjusted close is never preferred over the close. To use a different column, name it
with the keyword of the same role:

```julia
sma(df; close = :AdjClose)
atr(df; high = :H, low = :L, close = :C)
```

Indicators that use a single series read the close column. If the table has no close
column but exactly one numeric column besides the time column, that column is used.

Columns may have element type `Union{Missing,T}` as long as they contain no missing
values.

## Time column

The first column whose element type is a `Dates.TimeType` (for example `Date` or
`DateTime`) is copied into the output, so each result row keeps its timestamp. Choose a
different column with `timestamp = :Col`, or leave it out with `timestamp = nothing`.

## Output

The result has the same table type as the input (via `Tables.materializer`): a
`DataFrame` in gives a `DataFrame` out. Table types without a materializer, such as
`CSV.File` and `TimeArray`, give a `NamedTuple` of vectors, which converts to anything
else, e.g. `TimeArray(out; timestamp = :timestamp)`.

The output columns are named after the indicator for single-output indicators (`sma`,
`atr`, ...), take the indicator's output keys for multi-output indicators (`lower`,
`mid`, `upper` for `bbands`), and are `lag0`, `lag1`, ... for `runacf`.

## Two-series functions

`runcov`, `runcor`, `crossover` and `crossunder` compare two series and take vectors
only. To compare columns of different tables, join the tables first and pass the
columns.
