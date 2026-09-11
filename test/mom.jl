@testset "Momentum" begin
    Random.seed!(SEED)
    c = cumsum(randn(N))
    o = [c[1]; c[1:(end-1)]]
    h = max.(o, c) .+ rand(N)
    l = min.(o, c) .- rand(N)
    for f in (momentum, roc, rsi, kst)
        @test valid(f(c))
    end
    @test valid(psar(h, l))
    @test valid(wpr(h, l, c))
    @test valid(cci(h, l, c))
    for (tmp, names) in (
        (aroon(h, l), (:up, :down, :osc)),
        (donch(h, l), (:lower, :mid, :upper)),
        (ichimoku(h, l, c), (:tenkan, :kijun, :senkou_a, :senkou_b, :chikou)),
        (macd(c), (:macd, :signal, :histogram)),
        (adx(h, l, c), (:di_plus, :di_minus, :adx)),
        (adx(h, l, c; wilder = true), (:di_plus, :di_minus, :adx)),
        (heikinashi(o, h, l, c), (:open, :high, :low, :close)),
        (stoch(h, l, c; kind = :fast), (:k, :d)),
        (stoch(h, l, c; kind = :slow), (:k, :d)),
        (smi(h, l, c), (:smi, :signal)),
    )
        @test keys(tmp) == names
        @test valid(tmp)
    end
    @test @inferred(macd(c)) isa NamedTuple
    @test @inferred(adx(h, l, c)) isa NamedTuple
    @test @inferred(stoch(h, l, c)) isa NamedTuple
    @test_throws DimensionMismatch stoch(h, l, c[1:(end-1)])
end
