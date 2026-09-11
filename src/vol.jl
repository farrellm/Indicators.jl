"""
```
bbands(x::AbstractVector{<:Real}; n::Int=10, mult::Real=2.0, ma::Function=sma, args...)
```

Bollinger bands (moving average with standard deviation bands)

Extra keyword arguments are passed to the moving average `ma`.

*Output*

A NamedTuple `(lower, mid, upper)`: the moving average and the bands `mult` rolling
standard deviations below and above it.
"""
function bbands(
    x::AbstractVector{<:Real};
    n::Int = 10,
    mult::Real = 2.0,
    ma::Function = sma,
    args...,
)
    @assert n<length(x) && n>0 "Argument n is out of bounds."
    mid = ma(x; n = n, args...)
    sd = runsd(x, n = n, cumulative = false)
    return (lower = mid .- mult .* sd, mid = mid, upper = mid .+ mult .* sd)
end

"""
```
tr(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real})::Vector{Float64}
```

True range
"""
function tr(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real},
)::Vector{Float64}
    n = _checklengths(high, low, close)
    out = zeros(n)
    out[1] = NaN
    @inbounds for i in 2:n
        out[i] = max(high[i]-low[i], high[i]-close[i-1], close[i-1]-low[i])
    end
    return out
end

"""
```
atr(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real}; n::Int=14, ma::Function=ema)::Vector{Float64}
```

Average true range (uses exponential moving average)
"""
function atr(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real};
    n::Int = 14,
    ma::Function = ema,
)::Vector{Float64}
    N = _checklengths(high, low, close)
    @assert n<N && n>0 "Argument n out of bounds."
    return [NaN; ma(tr(high, low, close)[2:end], n = n)]
end

"""
```
keltner(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real}; nema::Int=20, natr::Int=10, mult::Real=2)
```

Keltner bands

*Output*

A NamedTuple `(lower, mid, upper)`: the `nema`-period EMA of the close and the bands
`mult` average true ranges below and above it.
"""
function keltner(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real};
    nema::Int = 20,
    natr::Int = 10,
    mult::Real = 2,
)
    _checklengths(high, low, close)
    mid = ema(close, n = nema)
    a = atr(high, low, close, n = natr)
    return (lower = mid .- mult .* a, mid = mid, upper = mid .+ mult .* a)
end
