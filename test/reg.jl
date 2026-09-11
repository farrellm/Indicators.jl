# moving regressions
@testset "Regressions" begin
    Random.seed!(SEED)
    x = cumsum(randn(N))
    tmp = mlr_beta(x)
    @test keys(tmp) == (:intercept, :slope)
    @test valid(tmp)
    @test isequal(tmp.slope, mlr_slope(x))
    for f in (mlr_slope, mlr_intercept, mlr, mlr_se, mlr_ub, mlr_lb)
        @test valid(f(x))
    end
    tmp = mlr_bands(x)
    @test keys(tmp) == (:lower, :mid, :upper)
    @test valid(tmp)
    @test isequal(tmp.mid, mlr(x))
    for adjusted in (true, false)
        @test valid(mlr_rsq(x; adjusted))
    end
    # a straight line is fit exactly
    line = 2.0 .* (1:N) .+ 3.0
    @test mlr_slope(line)[10:end] ≈ fill(2.0, N-9)
    @test mlr_beta(line; x = collect(1.0:N)).intercept[10:end] ≈ fill(3.0, N-9)
end
