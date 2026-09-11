@testset "Utilities" begin
    @testset "Crossover/Crossunder" begin
        Random.seed!(SEED)
        x = cumsum(randn(N)) .+ X0
        y = x + randn(N)
        cxo = crossover(x, y)
        cxu = crossunder(x, y)
        @test any(cxo)
        @test any(cxu)
        @test !any(cxo .* cxu)  # ensure crossovers and crossunders never coincide
        @test_throws DimensionMismatch crossover(x, y[1:(end-1)])
    end
    @testset "Differencing" begin
        x = [1.0, 2.0, 4.0, 7.0]
        @test isequal(diffn(x), [NaN, 1.0, 2.0, 3.0])
        @test isequal(diffn(x; n = 2), [NaN, NaN, 3.0, 5.0])
    end
end
