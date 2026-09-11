# Momentum-oriented technical indicator functions

"""
```
aroon(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}; n::Int=25)
```

Aroon up/down/oscillator

*Output*

A NamedTuple `(up, down, osc)`.
"""
function aroon(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}; n::Int = 25)
    N = _checklengths(high, low)
    @assert 0<n<N "Argument `n` must be positive and less than the length of the input."
    up = fill(NaN, N)
    down = fill(NaN, N)
    # Look back over the current bar plus the previous `n` (the TTR convention); the
    # position of the extreme within that window gives the periods since it occurred.
    @inbounds for i in (n+1):N
        up[i] = 100.0 * (argmax(view(high, (i-n):i)) - 1) / n
        down[i] = 100.0 * (argmin(view(low, (i-n):i)) - 1) / n
    end
    return (up = up, down = down, osc = up .- down)
end

"""
```
donch(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}; n::Int=10, inclusive::Bool=true)
```

Donchian channel (if inclusive is set to true, will include current bar in calculations.)

*Output*

A NamedTuple `(lower, mid, upper)`: the lowest low, the average of the lowest low and
highest high, and the highest high of the last `n` periods.
"""
function donch(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real};
    n::Int = 10,
    inclusive::Bool = true,
)
    _checklengths(high, low)
    lower = runmin(low, n = n, cumulative = false, inclusive = inclusive)
    upper = runmax(high, n = n, cumulative = false, inclusive = inclusive)
    return (lower = lower, mid = (lower .+ upper) ./ 2.0, upper = upper)
end

function shft(x::AbstractVector{T} where {T<:Number}, n::Integer)
    if n == 0
        return x
    elseif n < 0
        return vcat(x[(1-n):end], fill(NaN, -n))
    else
        return vcat(fill(NaN, n), x[1:(end-n)])
    end
end

"""
```
ichimoku(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real}; params=(9, 26, 26, 52, -26))
```

Ichimoku Kinko Hyo

*Output*

A NamedTuple `(tenkan, kijun, senkou_a, senkou_b, chikou)`.
"""
function ichimoku(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real};
    params = (9, 26, 26, 52, -26),
)
    # Source: https://www.investopedia.com/terms/i/ichimokuchart.asp
    # TODO: Implement option to get forward looking Senkous
    _checklengths(high, low, close)
    tenkan = donch(high, low; n = params[1], inclusive = true).mid
    kijun = donch(high, low; n = params[2], inclusive = true).mid
    senkou_a = shft((tenkan .+ kijun) ./ 2, params[3])
    senkou_b = shft(donch(high, low; n = params[4], inclusive = true).mid, params[3])
    chikou = shft(convert(Vector{Float64}, close), params[5])
    return (
        tenkan = tenkan,
        kijun = kijun,
        senkou_a = senkou_a,
        senkou_b = senkou_b,
        chikou = chikou,
    )
end

"""
```
momentum(x::AbstractVector{<:Real}; n::Int=1)::Vector{Float64}
```

Momentum indicator (price now vs price `n` periods back)
"""
function momentum(x::AbstractVector{<:Real}; n::Int = 1)::Vector{Float64}
    @assert n>0 "Argument n must be positive."
    return diffn(x, n = n)
end

"""
```
roc(x::AbstractVector{<:Real}; n::Int=1)::Vector{Float64}
```

Rate of change indicator (percent change between i'th observation and (i-n)'th observation)
"""
function roc(x::AbstractVector{<:Real}; n::Int = 1)::Vector{Float64}
    @assert n<length(x) && n>0 "Argument n out of bounds."
    out = fill(NaN, length(x))
    @inbounds for i in (n+1):length(x)
        out[i] = 100.0 * (x[i]/x[i-n] - 1.0)
    end
    return out
end

"""
```
macd(x::AbstractVector{<:Real}; nfast::Int=12, nslow::Int=26, nsig::Int=9, fast_ma::Function=ema, slow_ma::Function=ema, signal_ma::Function=sma)
```

Moving average convergence-divergence

*Output*

A NamedTuple `(macd, signal, histogram)`.
"""
function macd(
    x::AbstractVector{<:Real};
    nfast::Int = 12,
    nslow::Int = 26,
    nsig::Int = 9,
    fast_ma::Function = ema,
    slow_ma::Function = ema,
    signal_ma::Function = sma,
)
    m = fast_ma(x, n = nfast) .- slow_ma(x, n = nslow)
    s = signal_ma(m, n = nsig)
    return (macd = m, signal = s, histogram = m .- s)
end

"""
```
rsi(x::AbstractVector{<:Real}; n::Int=14, ma::Function=ema, args...)::Vector{Float64}
```

Relative strength index

Extra keyword arguments are passed to the moving average `ma`.
"""
function rsi(
    x::AbstractVector{<:Real};
    n::Int = 14,
    ma::Function = ema,
    args...,
)::Vector{Float64}
    @assert n<length(x) && n>0 "Argument n is out of bounds."
    N = length(x)
    ups = zeros(N)
    dns = zeros(N)
    @inbounds for i in 2:N
        dx = x[i] - x[i-1]
        if dx > 0
            ups[i] = dx
        elseif dx < 0
            dns[i] = -dx
        end
    end
    rs = [NaN; ma(ups[2:end]; n = n, args...) ./ ma(dns[2:end]; n = n, args...)]
    return 100.0 .- 100.0 ./ (1.0 .+ rs)
end

"""
```
adx(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real}; n::Int=14, ma::Function=ema, args...)
```

Average directional index

Extra keyword arguments are passed to the moving average `ma`, e.g. `wilder=true` for
Wilder smoothing with the default `ema`.

*Output*

A NamedTuple `(di_plus, di_minus, adx)`.
"""
function adx(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real};
    n::Int = 14,
    ma::Function = ema,
    args...,
)
    N = _checklengths(high, low, close)
    @assert n<N && n>0 "Argument n is out of bounds."
    updm = zeros(N)
    dndm = zeros(N)
    updm[1] = dndm[1] = NaN
    @inbounds for i in 2:N
        upmove = high[i] - high[i-1]
        dnmove = low[i-1] - low[i]
        if upmove > dnmove && upmove > 0.0
            updm[i] = upmove
        elseif dnmove > upmove && dnmove > 0.0
            dndm[i] = dnmove
        end
    end
    a = atr(high, low, close, n = n)
    dip = [NaN; ma(updm[2:N]; n = n, args...)] ./ a .* 100.0
    dim = [NaN; ma(dndm[2:N]; n = n, args...)] ./ a .* 100.0
    dmx = abs.(dip .- dim) ./ (dip .+ dim)
    adxs = [fill(NaN, n); ma(dmx[(n+1):N]; n = n, args...)] .* 100.0
    return (di_plus = dip, di_minus = dim, adx = adxs)
end

"""
```
heikinashi(open::AbstractVector{<:Real}, high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real})
```

Heikin Ashi

*Output*

A NamedTuple `(open, high, low, close)`:

- open -- previous (o+c)/2
- high -- max(o,h)
- low -- min(o,l)
- close -- (o+h+l+c)/4
"""
function heikinashi(
    open::AbstractVector{<:Real},
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real},
)
    N = _checklengths(open, high, low, close)
    hao = [NaN; (open[1:(N-1)] .+ close[1:(N-1)]) ./ 2.0]
    hah = max.(hao, high)
    hal = min.(hao, low)
    hac = (open .+ high .+ low .+ close) ./ 4.0
    return (open = hao, high = hah, low = hal, close = hac)
end


"""
```
psar(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}; af_min::Real=0.02, af_max::Real=0.2, af_inc::Real=af_min)::Vector{Float64}
```

Parabolic stop and reverse (SAR)

*Arguments*
- `high`, `low`: high and low prices
- `af_min`: starting/initial value for acceleration factor
- `af_max`: maximum acceleration factor (accel factor capped at this value)
- `af_inc`: increment to the acceleration factor (speed of increase in accel factor)
"""
function psar(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real};
    af_min::Real = 0.02,
    af_max::Real = 0.2,
    af_inc::Real = af_min,
)::Vector{Float64}
    @assert af_min<1.0 && af_min>0.0 "Argument af_min must be in [0,1]."
    @assert af_max<1.0 && af_max>0.0 "Argument af_max must be in [0,1]."
    @assert af_inc<1.0 && af_inc>0.0 "Argument af_inc must be in [0,1]."
    N = _checklengths(high, low)
    amin = Float64(af_min)
    amax = Float64(af_max)
    ainc = Float64(af_inc)
    ls0 = 1
    ls = 0
    af0 = amin
    af = 0.0
    ep0 = Float64(high[1])
    ep = 0.0
    maxi = 0.0
    mini = 0.0
    sar = zeros(N)
    sar[1] = low[1] - std(high .- low)
    @inbounds for i in 2:N
        ls = ls0
        ep = ep0
        af = af0
        mini = min(low[i-1], low[i])
        maxi = max(high[i-1], high[i])
        # Long/short signals and local extrema
        if (ls == 1)
            ls0 = low[i] > sar[i-1] ? 1 : -1
            ep0 = max(maxi, ep)
        else
            ls0 = high[i] < sar[i-1] ? -1 : 1
            ep0 = min(mini, ep)
        end
        # Acceleration vector
        if ls0 == ls  # no signal change
            sar[i] = sar[i-1] + af*(ep-sar[i-1])
            af0 = (af == amax) ? amax : (af + ainc)
            if ls0 == 1  # current long signal
                af0 = (ep0 > ep) ? af0 : af
                sar[i] = min(sar[i], mini)
            else  # current short signal
                af0 = (ep0 < ep) ? af0 : af
                sar[i] = max(sar[i], maxi)
            end
        else  # new signal
            af0 = amin
            sar[i] = ep0
        end
    end
    return sar
end

"""
```
kst(x::AbstractVector{<:Real}; nroc::AbstractVector{<:Integer}=[10,15,20,30], navg::AbstractVector{<:Integer}=[10,10,10,15], wgts::AbstractVector{<:Real}=collect(1:length(nroc)), ma::Function=sma)::Vector{Float64}
```

KST (Know Sure Thing) -- smoothed and summed rates of change
"""
function kst(
    x::AbstractVector{<:Real};
    nroc::AbstractVector{<:Integer} = [10, 15, 20, 30],
    navg::AbstractVector{<:Integer} = [10, 10, 10, 15],
    wgts::AbstractVector{<:Real} = collect(1:length(nroc)),
    ma::Function = sma,
)::Vector{Float64}
    @assert length(nroc) == length(navg)
    @assert all(nroc .> 0) && all(nroc .< length(x))
    @assert all(navg .> 0) && all(navg .< length(x))
    out = zeros(length(x))
    @inbounds for j in eachindex(nroc)
        out .+= ma(roc(x, n = nroc[j]), n = navg[j]) .* wgts[j]
    end
    return out
end

"""
```
wpr(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real}; n::Int=14)::Vector{Float64}
```

Williams %R
"""
function wpr(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real};
    n::Int = 14,
)::Vector{Float64}
    _checklengths(high, low, close)
    hihi = runmax(high, n = n, cumulative = false)
    lolo = runmin(low, n = n, cumulative = false)
    return -100 .* (hihi .- close) ./ (hihi .- lolo)
end

"""
```
cci(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real}; n::Int=20, c::Real=0.015, ma::Function=sma, args...)::Vector{Float64}
```

Commodity channel index

Extra keyword arguments are passed to the moving average `ma`.
"""
function cci(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real};
    n::Int = 20,
    c::Real = 0.015,
    ma::Function = sma,
    args...,
)::Vector{Float64}
    _checklengths(high, low, close)
    tp = (high .+ low .+ close) ./ 3.0
    dev = runmad(tp, n = n, cumulative = false, fun = mean)
    avg = ma(tp; n = n, args...)
    return (tp .- avg) ./ (c .* dev)
end

"""
```
stoch(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real}; nk::Int=14, nd::Int=3, kind::Symbol=:fast, ma::Function=sma, args...)
```

Stochastic oscillator (fast or slow)

Extra keyword arguments are passed to the moving average `ma`.

*Output*

A NamedTuple `(k, d)` of the %K and %D lines.
"""
function stoch(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real};
    nk::Int = 14,
    nd::Int = 3,
    kind::Symbol = :fast,
    ma::Function = sma,
    args...,
)
    N = _checklengths(high, low, close)
    @assert kind == :fast || kind == :slow "Argument `kind` must be either :fast or :slow"
    @assert nk<N && nk>0 "Argument `nk` out of bounds."
    @assert nd<N && nd>0 "Argument `nd` out of bounds."
    hihi = runmax(high, n = nk, cumulative = false)
    lolo = runmin(low, n = nk, cumulative = false)
    k = (close .- lolo) ./ (hihi .- lolo) .* 100.0
    d = ma(k; n = nd, args...)
    if kind == :slow
        k = d
        d = ma(k; n = nd, args...)
    end
    return (k = k, d = d)
end

"""
```
smi(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real}; n::Int=13, nfast::Int=2, nslow::Int=25, nsig::Int=9, fast_ma::Function=ema, slow_ma::Function=ema, signal_ma::Function=sma)
```

SMI (stochastic momentum oscillator)

*Output*

A NamedTuple `(smi, signal)`.
"""
function smi(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real};
    n::Int = 13,
    nfast::Int = 2,
    nslow::Int = 25,
    nsig::Int = 9,
    fast_ma::Function = ema,
    slow_ma::Function = ema,
    signal_ma::Function = sma,
)
    _checklengths(high, low, close)
    hihi = runmax(high, n = n, cumulative = false)
    lolo = runmin(low, n = n, cumulative = false)
    hldif = hihi .- lolo
    delta = close .- (hihi .+ lolo) ./ 2.0
    numer = slow_ma(fast_ma(delta, n = nfast), n = nslow)
    denom = slow_ma(fast_ma(hldif, n = nfast), n = nslow) ./ 2.0
    s = 100.0 .* (numer ./ denom)
    return (smi = s, signal = signal_ma(s, n = nsig))
end
