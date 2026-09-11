# Miscellaneous utilities

# Length shared by all input series; throws if they differ
function _checklengths(xs::AbstractVector...)
    n = length(first(xs))
    all(x -> length(x) == n, xs) || throw(
        DimensionMismatch("input series must have equal lengths, got $(map(length, xs))"),
    )
    return n
end

"""
```
crossover(x::AbstractVector{<:Real}, y::AbstractVector{<:Real})::BitVector
```

Find where `x` crosses over `y` (returns boolean vector where crossover occurs)
"""
function crossover(x::AbstractVector{<:Real}, y::AbstractVector{<:Real})::BitVector
    n = _checklengths(x, y)
    out = falses(n)
    @inbounds for i in 2:n
        out[i] = ((x[i] > y[i]) && (x[i-1] < y[i-1]))
    end
    return out
end

"""
```
crossunder(x::AbstractVector{<:Real}, y::AbstractVector{<:Real})::BitVector
```

Find where `x` crosses under `y` (returns boolean vector where crossunder occurs)
"""
function crossunder(x::AbstractVector{<:Real}, y::AbstractVector{<:Real})::BitVector
    n = _checklengths(x, y)
    out = falses(n)
    @inbounds for i in 2:n
        out[i] = ((x[i] < y[i]) && (x[i-1] > y[i-1]))
    end
    return out
end

"""
```
wilder_sum(x::AbstractVector{<:Real}; n::Int=10)::Vector{Float64}
```

Welles Wilder summation of an array
"""
function wilder_sum(x::AbstractVector{<:Real}; n::Int = 10)::Vector{Float64}
    @assert n<length(x) && n>0 "Argument n is out of bounds."
    nf = float(n)  # type stability -- all arithmetic done on floats
    out = zeros(length(x))
    out[1] = x[1]
    @inbounds for i in 2:length(x)
        out[i] = x[i] + out[i-1]*(nf-1.0)/nf
    end
    return out
end

"""
```
diffn(x::AbstractVector{<:Real}; n::Int=1)::Vector{Float64}
```

Lagged differencing
"""
function diffn(x::AbstractVector{<:Real}; n::Int = 1)::Vector{Float64}
    @assert n<length(x) && n>0 "Argument n out of bounds."
    dx = zeros(length(x))
    dx[1:n] .= NaN
    @inbounds for i in (n+1):length(x)
        dx[i] = x[i] - x[i-n]
    end
    return dx
end
