# moving average functions
@testset "Moving Averages" begin
    Random.seed!(SEED)
    @testset "Array" begin
        x = cumsum(randn(N))
        X = cumsum(randn(N, 2), dims = 1)
        tmp = sma(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = mama(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 2
        @test sum(isnan.(tmp)) != N
        tmp = ema(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = wma(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = hma(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = trima(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = mma(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = tema(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = dema(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = swma(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = kama(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = alma(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = zlema(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        @test sum(isnan.(tmp)) != N
        tmp = vwma(X)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        tmp = vwap(X)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
        tmp = hama(x)
        @test size(tmp, 1) == N
        @test size(tmp, 2) == 1
    end
end
