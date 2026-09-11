@testset "Running Calculations" begin
    Random.seed!(SEED)
    x = cumsum(randn(N))
    y = x .* rand(N)
    @test valid(diffn(x))
    @test valid(wilder_sum(x))
    for cumulative in (true, false)
        @test valid(runmean(x; cumulative))
        @test valid(runsum(x; cumulative))
        @test valid(runmad(x; cumulative))
        @test valid(runvar(x; cumulative))
        @test valid(runsd(x; cumulative))
        @test valid(runcov(x, y; cumulative))
        @test valid(runcor(x, y; cumulative))
        for inclusive in (true, false)
            @test valid(runmax(x; cumulative, inclusive))
            @test valid(runmin(x; cumulative, inclusive))
        end
    end
    @test runsum(x)[10:end] ≈ cumsum(x)[10:end]
    @test runmean(x; cumulative = false)[10] ≈ mean(x[1:10])
    @test_throws DimensionMismatch runcor(x, y[1:(end-1)])
    tmp = runquantile(x, cumulative = true)
    @test !isnan(tmp[2]) && isnan(tmp[1])
    @test tmp[10] == quantile(x[1:10], 0.05)
    tmp = runquantile(x, cumulative = false)
    @test tmp[10] == quantile(x[1:10], 0.05)
    n = 20
    for cumulative in (true, false)
        tmp = runacf(x; n, maxlag = 15, cumulative)
        @test size(tmp) == (N, 16)
        @test all(tmp[n:end, 1] .== 1.0)
    end
end
