"""
Renko chart patterns

# Methods

```
renko(close::AbstractVector{<:Real}; box_size::Real=10.0)::Vector{Int}
renko(high::AbstractVector{<:Real}, low::AbstractVector{<:Real}, close::AbstractVector{<:Real}; box_size::Real=10.0, use_atr::Bool=false, n::Int=14)::Vector{Int}
```

- Traditional (Constant Box Size): `renko(close; box_size=10.0)`
- ATR Dynamic Box Size: `renko(high, low, close; use_atr=true, n=14)`, where the box size
  at each bar is the `n`-period average true range

# Output

`Vector{Int}` giving the Renko bar number of each observation.
"""
function renko(close::AbstractVector{<:Real}; box_size::Real = 10.0)::Vector{Int}
    # Renko chart bar identification with traditional methodology (constant box size)
    @assert box_size != 0 "Argument `box_size` must be nonzero."
    return _renko(close, i -> abs(box_size))
end

function renko(
    high::AbstractVector{<:Real},
    low::AbstractVector{<:Real},
    close::AbstractVector{<:Real};
    box_size::Real = 10.0,
    use_atr::Bool = false,
    n::Int = 14,
)::Vector{Int}
    # Renko chart bar identification with option to use ATR or traditional method (constant box size)
    _checklengths(high, low, close)
    if use_atr
        box_sizes = atr(high, low, close, n = n)
        return _renko(close, i -> box_sizes[i])
    else
        return renko(close, box_size = box_size)
    end
end

# Start a new bar whenever the price moves at least `box(i)` from the last reference point
function _renko(x::AbstractVector{<:Real}, box)::Vector{Int}
    bar_id = ones(Int, length(x))
    ref_pt = x[1]
    @inbounds for i in 2:length(x)
        bar_id[i] = bar_id[i-1]
        if abs(x[i]-ref_pt) >= box(i)
            ref_pt = x[i]
            bar_id[i] += 1
        end
    end
    return bar_id
end
