# volatility functions
@testset "Volatility" begin
    Random.seed!(SEED)
    c = cumsum(randn(N))
    h = c .+ rand(N)
    l = c .- rand(N)
    tmp = bbands(c)
    @test keys(tmp) == (:lower, :mid, :upper)
    @test valid(tmp)
    @test @inferred(bbands(c)) isa NamedTuple
    @test valid(tr(h, l, c))
    @test valid(atr(h, l, c))
    tmp = keltner(h, l, c)
    @test keys(tmp) == (:lower, :mid, :upper)
    @test valid(tmp)
    @test_throws DimensionMismatch atr(h, l, c[1:(end-1)])
end
