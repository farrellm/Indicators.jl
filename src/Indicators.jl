module Indicators

using Statistics

export
    runmean, runsum, runvar, runsd, runcov, runcor, runmax, runmin, runmad, runquantile,
    runacf, runfun,
    wilder_sum, diffn,
    sma, trima, wma, ema, mma, kama, mama, hma, swma, dema, tema, alma, zlema, vwma, vwap,
    hama,
    mlr_beta, mlr_slope, mlr_intercept, mlr, mlr_se, mlr_ub, mlr_lb, mlr_bands, mlr_rsq,
    aroon, donch, ichimoku, momentum, roc, macd, rsi, adx, psar, kst, wpr, cci, stoch, smi,
    bbands, tr, atr, keltner,
    crossover, crossunder,
    renko, heikinashi,
    maxima, minima, support, resistance,
    rsrange, hurst

include("run.jl")
include("ma.jl")
include("reg.jl")
include("mom.jl")
include("vol.jl")
include("trendy.jl")
include("utils.jl")
include("patterns.jl")
include("chaos.jl")

# Explain how to pass several series, or a table, when an indicator is given neither
function _input_hint(io::IO, exc::MethodError, argtypes, kwargs)
    f = exc.f
    (f isa Function && parentmodule(f) === Indicators && !isempty(argtypes)) || return
    T = argtypes[1]
    T isa Type || return
    if T <: AbstractMatrix
        print(
            io,
            "\nMatrix input was removed in Indicators 0.9: pass each series as a separate ",
            "vector, e.g. `atr(high, low, close)`, or pass a table.",
        )
    elseif !(T <: AbstractVector{<:Real}) &&
           Base.get_extension(Indicators, :IndicatorsTablesExt) === nothing
        print(
            io,
            "\nTo pass a table (DataFrame, CSV.File, TimeArray, NamedTuple of vectors, ...), ",
            "load Tables.jl or a package that uses it, e.g. `using DataFrames`.",
        )
    end
    return
end

function __init__()
    Base.Experimental.register_error_hint(_input_hint, MethodError)
end
end
