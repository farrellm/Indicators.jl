# Regression tests for bugs fixed in 0.9
@testset "Bug fixes" begin
    Random.seed!(SEED)
    x = 100.0 .+ cumsum(randn(N))
    h = x .+ rand(N)
    l = x .- rand(N)
    v = rand(1.0:1000.0, N)

    @testset "Float32 input" begin
        x32 = Float32.(x)
        for f in
            (sma, trima, wma, ema, mma, dema, tema, mama, hma, swma, kama, alma, zlema,
            hama, mlr_beta, mlr_slope, mlr_intercept, mlr, mlr_se, mlr_ub, mlr_lb,
            mlr_bands, mlr_rsq, momentum, roc, macd, rsi, kst, bbands, runmean, runsum,
            runvar, runsd, runmad, runmax, runmin, runquantile, runacf, wilder_sum, diffn,
            maxima, minima, support, resistance, renko, hurst, rsrange)
            @test size(f(x32), 1) == N
        end
        @test size(runcov(x32, x32 .+ 1.0f0), 1) == N
        @test size(runcor(x32, x32 .+ 1.0f0), 1) == N
        for f in (psar, donch, aroon)
            @test size(f(Float32.([h l])), 1) == N
        end
        for f in (tr, atr, adx, wpr, cci, stoch, smi, keltner, ichimoku)
            @test size(f(Float32.([h l x])), 1) == N
        end
        @test size(heikinashi(Float32.([x h l x])), 1) == N
        @test size(vwma(Float32.([x v])), 1) == N
        @test size(vwap(Float32.([x v])), 1) == N
    end

    @testset "Int input" begin
        xi = round.(Int, x)
        for f in (sma, ema, wma, diffn, wilder_sum, runquantile, maxima, minima, renko,
            momentum, roc, macd, rsi, bbands, mlr, mlr_bands)
            @test size(f(xi), 1) == N
        end
        @test size(runfun(xi, mean; n = 5), 1) == N
    end

    @testset "runfun" begin
        tmp = runfun(x, sum; n = 5)
        @test all(isnan, tmp[1:4])
        @test tmp[5:end] ≈ [sum(x[(i-4):i]) for i in 5:N]
        tmp = runfun(x, sum; n = 5, cumulative = true)
        @test tmp[5:end] ≈ cumsum(x)[5:end]
    end

    @testset "vwap" begin
        @test vwap([x v]) ≈ cumsum(x .* v) ./ cumsum(v)
    end

    @testset "aroon" begin
        rising = collect(1.0:N)  # the high is always the current bar, the low n bars ago
        tmp = aroon([rising rising .- 0.5]; n = 25)
        @test all(isnan, tmp[1:25, :])
        @test all(tmp[26:end, 1] .== 100.0)
        @test all(tmp[26:end, 2] .== 0.0)
        @test all(tmp[26:end, 3] .== 100.0)
    end

    @testset "alma" begin
        @test alma(fill(5.0, N))[9:end] ≈ fill(5.0, N-8)
        # the default offset (0.85) weights recent prices more heavily than an SMA does
        ramp = collect(1.0:N)
        @test all(alma(ramp)[9:end] .> sma(ramp; n = 9)[9:end])
    end

    @testset "ichimoku default periods" begin
        @test isequal(ichimoku([h l x])[:, 1], donch([h l]; n = 9)[:, 2])
    end

    @testset "bbands forwards ma keywords" begin
        @test isequal(
            bbands(x; ma = ema, wilder = true)[:, 2],
            ema(x; n = 10, wilder = true),
        )
    end

    @testset "_acf" begin
        lagcor(a, b) =
            sum((a .- mean(a)) .* (b .- mean(b))) /
            sqrt(sum((a .- mean(a)) .^ 2) * sum((b .- mean(b)) .^ 2))
        r = Indicators._acf(x, [0, 1, 5])
        @test r[1] ≈ 1.0
        @test r[2] ≈ lagcor(x[1:(end-1)], x[2:end])
        @test r[3] ≈ lagcor(x[1:(end-5)], x[6:end])
    end
end
