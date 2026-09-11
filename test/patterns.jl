# chart patterns functions
@testset "Chart Patterns" begin
    Random.seed!(SEED)
    c = cumsum(randn(N))
    h = c .+ rand(N)
    l = c .- rand(N)
    for tmp in (
        renko(c; box_size = 1.0),
        renko(h, l, c; use_atr = true),
        renko(h, l, c; box_size = 1.0),
    )
        @test length(tmp) == N
        @test tmp[1] == 1
        @test issorted(tmp)
    end
    @test renko([0.0, 0.5, 1.0, 1.4, 2.1]; box_size = 1.0) == [1, 1, 2, 2, 3]
end
