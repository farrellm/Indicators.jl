# Autocorrelation of `x` at each lag in `lags` (lag k pairs x[t] with x[t+k])
function _acf(x::AbstractVector, lags::AbstractVector{Int})::Vector{Float64}
    @assert all(lags .< length(x)-2) "Lags must be less than length(x) - 2"
    return [cor(x[1:(end-k)], x[(1+k):end]) for k in lags]
end

"""
```
runmean(x::AbstractVector{<:Real}; n::Int=10, cumulative::Bool=true)::Vector{Float64}
```

Compute a running or rolling arithmetic mean of an array.
"""
function runmean(
    x::AbstractVector{T};
    n::Int = 10,
    cumulative::Bool = true,
)::Vector{Float64} where {T<:Real}
    @assert n<length(x) && n>1 "Argument n is out of bounds."
    out = zeros(length(x))
    out[1:(n-1)] .= NaN
    if cumulative
        fi = 1.0:length(x)
        @inbounds for i in n:length(x)
            out[i] = sum(x[1:i])/fi[i]
        end
    else
        # original shorter but slower version of the code below
        # @inbounds for i = n:size(x,1)
        #     out[i] = mean(x[i-n+1:i])
        # end
        n_current = 0
        s::T = 0
        @inbounds for i in 1:n
            if isfinite(x[i])
                s += x[i]
                n_current += 1
            end
        end
        out[n] = n_current == n ? s / n : NaN
        @inbounds for i in (n+1):length(x)
            if isfinite(x[i])
                s += x[i]
                n_current += 1
            end
            if isfinite(x[i-n])
                s -= x[i-n]
                n_current -= 1
            end
            out[i] = (n_current == n) ? s / n_current : NaN
        end
    end
    return out
end

"""
```
runsum(x::AbstractVector{<:Real}; n::Int=10, cumulative::Bool=true)::Vector{Float64}
```

Compute a running or rolling summation of an array.
"""
function runsum(
    x::AbstractVector{T};
    n::Int = 10,
    cumulative::Bool = true,
)::Vector{Float64} where {T<:Real}
    @assert n<length(x) && n>1 "Argument n is out of bounds."
    if cumulative
        out = convert(Vector{Float64}, cumsum(x))
        out[1:(n-1)] .= NaN
    else
        out = zeros(length(x))
        out[1:(n-1)] .= NaN
        # original shorter but slower version of the code below
        # @inbounds for i = n:size(x,1)
        #     out[i] = sum(x[i-n+1:i])
        # end
        n_current = 0
        s::T = 0
        @inbounds for i in 1:n
            if isfinite(x[i])
                s += x[i]
                n_current += 1
            end
        end
        out[n] = n_current == n ? s : NaN
        @inbounds for i in (n+1):length(x)
            if isfinite(x[i])
                s += x[i]
                n_current += 1
            end
            if isfinite(x[i-n])
                s -= x[i-n]
                n_current -= 1
            end
            out[i] = (n_current == n) ? s : NaN
        end
    end
    return out
end

"""
```
runmad(x::AbstractVector{<:Real}; n::Int=10, cumulative::Bool=true, fun::Function=median)::Vector{Float64}
```

Compute the running or rolling mean absolute deviation of an array
"""
function runmad(
    x::AbstractVector{<:Real};
    n::Int = 10,
    cumulative::Bool = true,
    fun::Function = median,
)::Vector{Float64}
    @assert n<length(x) && n>1 "Argument n is out of bounds."
    out = zeros(length(x))
    out[1:(n-1)] .= NaN
    center = 0.0
    if cumulative
        fi = collect(1.0:length(x))
        @inbounds for i in n:length(x)
            center = fun(x[1:i])
            out[i] = sum(abs.(x[1:i] .- center)) / fi[i]
        end
    else
        fn = float(n)
        @inbounds for i in n:length(x)
            center = fun(x[(i-n+1):i])
            out[i] = sum(abs.(x[(i-n+1):i] .- center)) / fn
        end
    end
    return out
end

"""
```
runvar(x::AbstractVector{<:Real}; n::Int=10, cumulative::Bool=true)::Vector{Float64}
```

Compute the running or rolling variance of an array
"""
function runvar(
    x::AbstractVector{<:Real};
    n::Int = 10,
    cumulative::Bool = true,
)::Vector{Float64}
    @assert n<length(x) && n>1 "Argument n is out of bounds."
    out = zeros(length(x))
    out[1:(n-1)] .= NaN
    if cumulative
        @inbounds for i in n:length(x)
            out[i] = var(x[1:i])
        end
    else
        @inbounds for i in n:length(x)
            out[i] = var(x[(i-n+1):i])
        end
    end
    return out
end

"""
```
runsd(x::AbstractVector{<:Real}; n::Int=10, cumulative::Bool=true)::Vector{Float64}
```

Compute the running or rolling standard deviation of an array
"""
function runsd(
    x::AbstractVector{<:Real};
    n::Int = 10,
    cumulative::Bool = true,
)::Vector{Float64}
    return sqrt.(runvar(x, n = n, cumulative = cumulative))
end

"""
```
runcov(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}; n::Int=10, cumulative::Bool=true)::Vector{Float64}
```

Compute the running or rolling covariance of two arrays
"""
function runcov(
    x::AbstractVector{<:Real},
    y::AbstractVector{<:Real};
    n::Int = 10,
    cumulative::Bool = true,
)::Vector{Float64}
    _checklengths(x, y)
    @assert n<length(x) && n>1 "Argument n is out of bounds."
    out = zeros(length(x))
    out[1:(n-1)] .= NaN
    if cumulative
        @inbounds for i in n:length(x)
            out[i] = cov(x[1:i], y[1:i])
        end
    else
        @inbounds for i in n:length(x)
            out[i] = cov(x[(i-n+1):i], y[(i-n+1):i])
        end
    end
    return out
end

"""
```
runcor(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}; n::Int=10, cumulative::Bool=true)::Vector{Float64}
```

Compute the running or rolling correlation of two arrays
"""
function runcor(
    x::AbstractVector{<:Real},
    y::AbstractVector{<:Real};
    n::Int = 10,
    cumulative::Bool = true,
)::Vector{Float64}
    _checklengths(x, y)
    @assert n<length(x) && n>1 "Argument n is out of bounds."
    out = zeros(length(x))
    out[1:(n-1)] .= NaN
    if cumulative
        @inbounds for i in n:length(x)
            out[i] = cor(x[1:i], y[1:i])
        end
    else
        @inbounds for i in n:length(x)
            out[i] = cor(x[(i-n+1):i], y[(i-n+1):i])
        end
    end
    return out
end

"""
```
runmax(x::AbstractVector{<:Real}; n::Int=10, cumulative::Bool=true, inclusive::Bool=true)::Vector{Float64}
```

Compute the running or rolling maximum of an array
"""
function runmax(
    x::AbstractVector{<:Real};
    n::Int = 10,
    cumulative::Bool = true,
    inclusive::Bool = true,
)::Vector{Float64}
    @assert n<length(x) && n>1 "Argument n is out of bounds."
    out = zeros(length(x))
    if inclusive
        if cumulative
            out[n] = maximum(x[1:n])
            @inbounds for i in (n+1):length(x)
                out[i] = max(out[i-1], x[i])
            end
        else
            @inbounds for i in n:length(x)
                out[i] = maximum(x[(i-n+1):i])
            end
        end
        out[1:(n-1)] .= NaN
        return out
    else
        if cumulative
            out[n+1] = maximum(x[1:n])
            @inbounds for i in (n+1):(length(x)-1)
                out[i+1] = max(out[i-1], x[i-1])
            end
        else
            @inbounds for i in n:(length(x)-1)
                out[i+1] = maximum(x[(i-n+1):i])
            end
        end
        out[1:n] .= NaN
        return out
    end
end

"""
```
runmin(x::AbstractVector{<:Real}; n::Int=10, cumulative::Bool=true, inclusive::Bool=true)::Vector{Float64}
```

Compute the running or rolling minimum of an array
"""
function runmin(
    x::AbstractVector{<:Real};
    n::Int = 10,
    cumulative::Bool = true,
    inclusive::Bool = true,
)::Vector{Float64}
    @assert n<length(x) && n>1 "Argument n is out of bounds."
    out = zeros(length(x))
    if inclusive
        if cumulative
            out[n] = minimum(x[1:n])
            @inbounds for i in (n+1):length(x)
                out[i] = min(out[i-1], x[i])
            end
        else
            @inbounds for i in n:length(x)
                out[i] = minimum(x[(i-n+1):i])
            end
        end
        out[1:(n-1)] .= NaN
        return out
    else
        if cumulative
            out[n+1] = minimum(x[1:n])
            @inbounds for i in (n+1):(length(x)-1)
                out[i+1] = min(out[i-1], x[i-1])
            end
        else
            @inbounds for i in n:(length(x)-1)
                out[i+1] = minimum(x[(i-n+1):i])
            end
        end
        out[1:n] .= NaN
        return out
    end
end

"""
```
runquantile(x::AbstractVector{<:Real}; p::Real=0.05, n::Int=10, cumulative::Bool=true)::Vector{Float64}
```

Compute the running/rolling quantile of an array
"""
function runquantile(
    x::AbstractVector{<:Real};
    p::Real = 0.05,
    n::Int = 10,
    cumulative::Bool = true,
)::Vector{Float64}
    @assert n<length(x) && n>1 "Argument n is out of bounds."
    out = zeros(length(x))
    if cumulative
        @inbounds for i in 2:length(x)
            out[i] = quantile(x[1:i], p)
        end
        out[1] = NaN
    else
        @inbounds for i in n:length(x)
            out[i] = quantile(x[(i-n+1):i], p)
        end
        out[1:(n-1)] .= NaN
    end
    return out
end

"""
```
runacf(x::AbstractVector{<:Real}; n::Int=10, maxlag::Int=n-3, lags::AbstractVector{Int}=0:maxlag, cumulative::Bool=true)::Matrix{Float64}
```

Compute the running/rolling autocorrelation of a vector.

*Output*

A matrix with one row per observation and one column per lag in `lags`.
"""
function runacf(
    x::AbstractVector{<:Real};
    n::Int = 10,
    maxlag::Int = n-3,
    lags::AbstractVector{Int} = 0:maxlag,
    cumulative::Bool = true,
)::Matrix{Float64}
    N = length(x)
    @assert n < N && n > 0
    if length(lags) == 1 && lags[1] == 0
        return ones(N, 1)
    end
    out = fill(NaN, N, length(lags))
    if cumulative
        @inbounds for i in n:N
            out[i, :] = _acf(x[1:i], lags)
        end
    else
        @inbounds for i in n:N
            out[i, :] = _acf(x[(i-n+1):i], lags)
        end
    end
    return out
end

"""
```
runfun(x::AbstractVector{<:Real}, f::Function; n::Int=10, cumulative::Bool=false, args...)::Vector{Float64}
```

Apply a general function `f` that returns a scalar over a rolling (or, if `cumulative`,
expanding) window of `x`. Extra keyword arguments are passed to `f`.
"""
function runfun(
    x::AbstractVector{<:Real},
    f::Function;
    n::Int = 10,
    cumulative::Bool = false,
    args...,
)::Vector{Float64}
    N = length(x)
    out = fill(NaN, N)
    if cumulative
        for i in n:N
            out[i] = f(x[1:i]; args...)
        end
    else
        for i in n:N
            out[i] = f(x[(i-n+1):i]; args...)
        end
    end
    return out
end
