# trendy
@testset "Trendlines" begin
    Random.seed!(SEED)
    x = cumsum(randn(N))
    @test valid(resistance(x))
    @test valid(support(x))
    @test length(maxima(x)) == N && any(maxima(x))
    @test length(minima(x)) == N && any(minima(x))
    @test maxima([1.0, 3.0, 2.0, 5.0, 4.0]) == [false, true, false, true, false]
end
