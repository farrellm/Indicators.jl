# analytical
@testset "Chaos" begin
    Random.seed!(SEED)
    # helpers
    x = randn(252)
    a, b = Indicators.divide(x)
    @test [a; b] == x
    x = randn(101)
    a, b = Indicators.divide(x)
    @test [a; b] == x
    # workhorses
    x = randn(N)
    @test valid(hurst(x, n = 100))
    @test valid(rsrange(x))
end
