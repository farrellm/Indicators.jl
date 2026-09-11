# Table input via the Tables.jl package extension

# Runs before Tables is loaded
@testset "Table support is optional" begin
    @test Base.get_extension(Indicators, :IndicatorsTablesExt) === nothing
    err = try
        sma((Close = [1.0, 2.0, 3.0],))
    catch e
        e
    end
    @test err isa MethodError && occursin("Tables.jl", sprint(showerror, err))
    err = try
        atr(rand(10, 3))
    catch e
        e
    end
    @test err isa MethodError && occursin("separate vector", sprint(showerror, err))
end

using Tables, DataFrames, Dates

@testset "Tables" begin
    @test Base.get_extension(Indicators, :IndicatorsTablesExt) !== nothing
    Random.seed!(SEED)
    c = 100.0 .+ cumsum(randn(N))
    o = [c[1]; c[1:(end-1)]]
    h = max.(o, c) .+ rand(N)
    l = min.(o, c) .- rand(N)
    v = rand(1.0:1000.0, N)
    d = Date(2024, 1, 1) .+ Day.(0:(N-1))
    nt = (Date = d, Open = o, High = h, Low = l, Close = c, Volume = v)
    df = DataFrame(nt)

    @testset "output type follows the input" begin
        @test sma(df; n = 20) isa DataFrame
        @test names(macd(df)) == ["Date", "macd", "signal", "histogram"]
        out = sma(nt; n = 20)
        @test out isa NamedTuple
        @test keys(out) == (:Date, :sma)
        @test out.Date == d
        @test isequal(out.sma, sma(c; n = 20))
        rows = Tables.rowtable(nt)
        @test isequal(Tables.columntable(sma(rows)).sma, sma(c))
    end

    @testset "column resolution" begin
        lower = (date = d, open = o, high = h, low = l, close = c)
        @test isequal(atr(lower).atr, atr(h, l, c))
        adj = (Date = d, AdjClose = 2 .* c, Close = c)
        @test isequal(sma(adj).sma, sma(c))  # no silent adjusted-close preference
        @test isequal(sma(adj; close = :AdjClose).sma, sma(2 .* c))
        @test isequal(sma((Date = d, Price = c)).sma, sma(c))  # the only numeric column
        err = try
            sma((Date = d, A = c, B = c))
        catch e
            e
        end
        @test err isa ArgumentError && occursin("available columns: Date, A, B", err.msg)
        @test_throws ArgumentError atr((High = h, Close = c))  # no low
        @test_throws ArgumentError atr((High = h, Low = l, Closed = c))  # no substring match
        @test_throws ArgumentError sma(nt; close = :Nope)
    end

    @testset "timestamp" begin
        @test keys(sma(nt; timestamp = nothing)) == (:sma,)
        @test keys(sma((Close = c,))) == (:sma,)
        two = (When = d, Other = d, Close = c)
        @test keys(sma(two)) == (:When, :sma)
        @test keys(sma(two; timestamp = :Other)) == (:Other, :sma)
        @test_throws ArgumentError sma(nt; timestamp = :Nope)
    end

    @testset "missing values" begin
        cm = Vector{Union{Missing,Float64}}(c)
        @test isequal(sma((Close = cm,)).sma, sma(c))
        cm[5] = missing
        @test_throws ArgumentError sma((Close = cm,))
    end

    @testset "role groups" begin
        @test keys(psar(nt)) == (:Date, :psar)
        @test keys(adx(nt)) == (:Date, :di_plus, :di_minus, :adx)
        @test isequal(adx(nt; wilder = true).adx, adx(h, l, c; wilder = true).adx)
        @test keys(heikinashi(nt)) == (:Date, :open, :high, :low, :close)
        @test isequal(bbands(nt; n = 20).upper, bbands(c; n = 20).upper)
        # vwap(::TS) used to compute VWMA
        @test isequal(vwap(nt).vwap, vwap(c, v))
        @test !isequal(vwap(nt).vwap, vwma(nt).vwma)
        @test keys(runacf(nt; n = 20, maxlag = 3)) == (:Date, :lag0, :lag1, :lag2, :lag3)
        @test isequal(runfun(nt, sum; n = 5).runfun, runfun(c, sum; n = 5))
        @test isequal(renko(nt; box_size = 1.0).renko, renko(c; box_size = 1.0))
        @test isequal(renko(nt; use_atr = true).renko, renko(h, l, c; use_atr = true))
    end

    @testset "non-tables" begin
        @test_throws ArgumentError sma([1.0, missing, 3.0])
        err = try
            atr(rand(10, 3))
        catch e
            e
        end
        @test err isa ArgumentError && occursin("separate vector", err.msg)
    end
end
