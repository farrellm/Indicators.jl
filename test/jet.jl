# Targeted JET checks: the numeric kernels must stay free of runtime dispatch. The
# table-facing methods in IndicatorsTablesExt are dynamic by design (Tables.getcolumn is not
# type-stable and the output type follows the input); they resolve the columns and then
# call these same vector methods, which is where the work happens and what is checked here.

using JET

const V = Vector{Float64}

@testset "JET" begin
    JET.test_package(Indicators; target_modules = (Indicators,))
    for (f, types) in (
        (sma, (V,)),
        (ema, (V,)),
        (macd, (V,)),
        (bbands, (V,)),
        (mlr_bands, (V,)),
        (runmean, (V,)),
        (runacf, (V,)),
        (renko, (V,)),
        (atr, (V, V, V)),
        (adx, (V, V, V)),
        (stoch, (V, V, V)),
        (psar, (V, V)),
        (vwap, (V, V)),
        (heikinashi, (V, V, V, V)),
        # Float32 input used to throw MethodError
        (ema, (Vector{Float32},)),
        (bbands, (Vector{Float32},)),
    )
        JET.test_opt(f, types; target_modules = (Indicators,))
    end
end
