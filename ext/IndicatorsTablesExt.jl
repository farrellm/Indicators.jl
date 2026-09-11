module IndicatorsTablesExt

# Table input for Indicators: find the price columns of any Tables.jl source, call the
# vector method, and return the result -- with the time column -- as the input's table type.

using Indicators
using Tables
using Dates: TimeType

const MATRIX_MSG = "matrix input was removed in Indicators 0.9: pass each series as a separate vector, e.g. `atr(high, low, close)`, or pass a table"

function _columns(tbl)
    tbl isa AbstractMatrix && throw(ArgumentError(MATRIX_MSG))
    Tables.istable(tbl) || throw(
        ArgumentError(
            "expected numeric vectors or a table (any Tables.jl source), got $(typeof(tbl))",
        ),
    )
    return Tables.columns(tbl)
end

_colnames(cols) = collect(Symbol, Tables.columnnames(cols))
_available(cols) = "available columns: " * join(_colnames(cols), ", ")
_isnumeric(col) = nonmissingtype(eltype(col)) <: Real

# Column `name` as a numeric vector; a Union{Missing,T} column must contain no missings
function _numeric(col, name::Symbol)
    _isnumeric(col) ||
        throw(ArgumentError("column `$name` is not numeric (element type $(eltype(col)))"))
    eltype(col) <: Real && return col
    any(ismissing, col) && throw(ArgumentError("column `$name` contains missing values"))
    return convert(Vector{nonmissingtype(eltype(col))}, col)
end

# Column playing `role` (:open, :high, :low, :close or :volume): the `override` column if
# given, else the column named `role` ignoring case
function _column(cols, role::Symbol, override, ts)
    names = _colnames(cols)
    if override !== nothing
        name = Symbol(override)
        name in names || throw(
            ArgumentError(
                "column `$name` given for `$role` not found; $(_available(cols))",
            ),
        )
        return _numeric(Tables.getcolumn(cols, name), name)
    end
    i = findfirst(n -> lowercase(String(n)) == String(role), names)
    if i === nothing && role === :close
        # a table with a single numeric (non-time) column is the series itself
        numeric = findall(n -> n !== ts && _isnumeric(Tables.getcolumn(cols, n)), names)
        length(numeric) == 1 && (i = only(numeric))
    end
    i === nothing && throw(
        ArgumentError(
            "no `$role` column found (names are matched exactly, ignoring case); " *
            "$(_available(cols)). Pass `$role = :Name` to choose one.",
        ),
    )
    return _numeric(Tables.getcolumn(cols, names[i]), names[i])
end

# Name of the time column to carry into the output: the first `TimeType` column for
# `:auto`, the named column, or none for `nothing`
function _timestamp(cols, timestamp)
    timestamp === nothing && return nothing
    names = _colnames(cols)
    if timestamp === :auto
        i = findfirst(
            n -> nonmissingtype(eltype(Tables.getcolumn(cols, n))) <: TimeType,
            names,
        )
        return i === nothing ? nothing : names[i]
    end
    name = Symbol(timestamp)
    name in names ||
        throw(ArgumentError("timestamp column `$name` not found; $(_available(cols))"))
    return name
end

_outcols(name::Symbol, v::AbstractVector) = NamedTuple{(name,)}((v,))
_outcols(::Symbol, nt::NamedTuple) = nt

function _wrap(tbl, cols, ts, out::NamedTuple)
    if ts !== nothing
        out = merge(NamedTuple{(ts,)}((Tables.getcolumn(cols, ts),)), out)
    end
    return Tables.materializer(tbl)(out)
end

# Indicators computed from the close, or from the table's only numeric column
const UNIVARIATE = (
    :runmean, :runsum, :runmad, :runvar, :runsd, :runmax, :runmin, :runquantile,
    :wilder_sum, :diffn, :sma, :trima, :wma, :ema, :mma, :dema, :tema, :mama, :hma,
    :swma,
    :kama, :alma, :zlema, :hama, :mlr_beta, :mlr_slope, :mlr_intercept, :mlr, :mlr_se,
    :mlr_ub, :mlr_lb, :mlr_bands, :mlr_rsq, :momentum, :roc, :macd, :rsi, :kst, :bbands,
    :maxima, :minima, :support, :resistance, :hurst, :rsrange,
)

const MULTISERIES = (
    (:high, :low) => (:psar, :donch, :aroon),
    (:high, :low, :close) =>
        (:tr, :atr, :adx, :wpr, :cci, :stoch, :smi, :keltner, :ichimoku),
    (:open, :high, :low, :close) => (:heikinashi,),
    (:close, :volume) => (:vwma, :vwap),
)

for (roles, fs) in ((:close,) => UNIVARIATE, MULTISERIES...), f in fs
    @eval function Indicators.$f(
        tbl;
        $([Expr(:kw, r, nothing) for r in roles]...),
        timestamp = :auto,
        kwargs...,
    )
        cols = _columns(tbl)
        ts = _timestamp(cols, timestamp)
        result = Indicators.$f(
            $([:(_column(cols, $(QuoteNode(r)), $r, ts)) for r in roles]...);
            kwargs...,
        )
        return _wrap(tbl, cols, ts, _outcols($(QuoteNode(f)), result))
    end
end

function Indicators.runfun(tbl, f::Function; close = nothing, timestamp = :auto, kwargs...)
    cols = _columns(tbl)
    ts = _timestamp(cols, timestamp)
    result = Indicators.runfun(_column(cols, :close, close, ts), f; kwargs...)
    return _wrap(tbl, cols, ts, (runfun = result,))
end

# One output column per lag: lag0, lag1, ...
function Indicators.runacf(
    tbl;
    close = nothing,
    timestamp = :auto,
    n::Int = 10,
    maxlag::Int = n-3,
    lags::AbstractVector{Int} = 0:maxlag,
    kwargs...,
)
    cols = _columns(tbl)
    ts = _timestamp(cols, timestamp)
    m = Indicators.runacf(_column(cols, :close, close, ts); n = n, lags = lags, kwargs...)
    names = Tuple(Symbol("lag", k) for k in lags)
    return _wrap(tbl, cols, ts, NamedTuple{names}(Tuple(m[:, j] for j in axes(m, 2))))
end

# Uses the close, plus the high and low when the box size comes from the ATR
function Indicators.renko(
    tbl;
    high = nothing,
    low = nothing,
    close = nothing,
    timestamp = :auto,
    use_atr::Bool = false,
    kwargs...,
)
    cols = _columns(tbl)
    ts = _timestamp(cols, timestamp)
    c = _column(cols, :close, close, ts)
    ids = if use_atr
        h = _column(cols, :high, high, ts)
        l = _column(cols, :low, low, ts)
        Indicators.renko(h, l, c; use_atr = true, kwargs...)
    else
        Indicators.renko(c; kwargs...)
    end
    return _wrap(tbl, cols, ts, (renko = ids,))
end

end
