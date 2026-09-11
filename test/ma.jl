# moving average functions
@testset "Moving Averages" begin
    Random.seed!(SEED)
    x = cumsum(randn(N))
    v = rand(N) .* 1000
    for f in (sma, ema, wma, hma, trima, mma, tema, dema, swma, kama, alma, zlema, hama)
        @test valid(f(x))
    end
    tmp = mama(x)
    @test keys(tmp) == (:mama, :fama)
    @test valid(tmp)
    @test @inferred(mama(x)) isa NamedTuple
    @test valid(vwma(x, v))
    @test valid(vwap(x, v))
    @test_throws DimensionMismatch vwma(x, v[1:(end-1)])
    @test sma(x; n = 5)[5] ≈ mean(x[1:5])
end
