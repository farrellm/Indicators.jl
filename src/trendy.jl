# Functions supporting trendline identification (support/resistance, zigzag, elliot waves, etc.)

"""
```
maxima(x::AbstractVector{<:Real}; threshold::Real=0.0, order::Int=1)::BitVector
```

Estimate local maxima of a time series
"""
function maxima(
    x::AbstractVector{<:Real};
    threshold::Real = 0.0,
    order::Int = 1,
)::BitVector
    @assert threshold >= 0.0 "threshold must be positive"
    @assert order > 0 "order must be a positive integer"
    n = length(x)
    crit = falses(n)
    @inbounds for i in 2:(n-1)
        if (x[i]-x[i-1] >= threshold) && (x[i]-x[i+1] >= threshold)
            crit[i] = true
        end
    end
    while order > 1
        idx = findall(crit)
        crit[idx[.!maxima(x[crit], threshold = threshold)]] .= false
        order -= 1
    end
    return crit
end

"""
```
minima(x::AbstractVector{<:Real}; threshold::Real=0.0, order::Int=1)::BitVector
```

Estimate local minima of a time series
"""
function minima(
    x::AbstractVector{<:Real};
    threshold::Real = 0.0,
    order::Int = 1,
)::BitVector
    @assert threshold <= 0.0 "threshold must be negative"
    @assert order > 0 "order must be a positive integer"
    n = length(x)
    crit = falses(n)
    @inbounds for i in 2:(n-1)
        if (x[i]-x[i-1] <= threshold) && (x[i]-x[i+1] <= threshold)
            crit[i] = true
        end
    end
    while order > 1
        idx = findall(crit)
        crit[idx[.!minima(x[crit], threshold = threshold)]] .= false
        order -= 1
    end
    return crit
end

function interpolate(x1::Int, x2::Int, y1::Real, y2::Real)
    m = (y2-y1)/(x2-x1)
    b = y1 - m*x1
    x = collect(x1:1.0:x2)
    y = m*x .+ b
    return y
end

"""
```
resistance(x::AbstractVector{<:Real}; order::Int=1, threshold::Real=0.0)::Vector{Float64}
```

Estimate resistance lines of a financial time series
"""
function resistance(
    x::AbstractVector{<:Real};
    order::Int = 1,
    threshold::Real = 0.0,
)::Vector{Float64}
    out = zeros(length(x))
    crit = maxima(x, threshold = threshold, order = order)
    out[.!crit] .= NaN
    idx = findall(crit)
    @inbounds for i in 2:length(idx)
        out[idx[i-1]:idx[i]] .= interpolate(idx[i-1], idx[i], x[idx[i-1]], x[idx[i]])
    end
    return out
end

"""
```
support(x::AbstractVector{<:Real}; order::Int=1, threshold::Real=0.0)::Vector{Float64}
```

Estimate support lines of a financial time series
"""
function support(
    x::AbstractVector{<:Real};
    order::Int = 1,
    threshold::Real = 0.0,
)::Vector{Float64}
    out = zeros(length(x))
    crit = minima(x, threshold = threshold, order = order)
    out[.!crit] .= NaN
    idx = findall(crit)
    @inbounds for i in 2:length(idx)
        out[idx[i-1]:idx[i]] .= interpolate(idx[i-1], idx[i], x[idx[i-1]], x[idx[i]])
    end
    return out
end
