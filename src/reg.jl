"""
```
mlr_beta(y::AbstractVector{<:Real}; n::Int=10, x::AbstractVector{<:Real}=collect(1.0:n))
```

Moving linear regression intercept and slope

*Output*

A NamedTuple `(intercept, slope)`.
"""
function mlr_beta(
    y::AbstractVector{<:Real};
    n::Int = 10,
    x::AbstractVector{<:Real} = collect(1.0:n),
)
    @assert n<length(y) && n>0 "Argument n out of bounds."
    @assert length(x) == n || length(x) == length(y)
    const_x = length(x) == n
    intercept = fill(NaN, length(y))
    slope = fill(NaN, length(y))
    ybar = runmean(y, n = n, cumulative = false)
    @inbounds for i in n:length(y)
        yi = y[(i-n+1):i]
        xi = const_x ? x : x[(i-n+1):i]
        slope[i] = cov(xi, yi) / var(xi)
        intercept[i] = ybar[i] - slope[i]*mean(xi)
    end
    return (intercept = intercept, slope = slope)
end

"""
```
mlr_slope(y::AbstractVector{<:Real}; n::Int=10, x::AbstractVector{<:Real}=collect(1.0:n))::Vector{Float64}
```

Moving linear regression slope
"""
function mlr_slope(
    y::AbstractVector{<:Real};
    n::Int = 10,
    x::AbstractVector{<:Real} = collect(1.0:n),
)::Vector{Float64}
    @assert n<length(y) && n>0 "Argument n out of bounds."
    @assert length(x) == n || length(x) == length(y)
    const_x = length(x) == n
    out = zeros(length(y))
    out[1:(n-1)] .= NaN
    @inbounds for i in n:length(y)
        yi = y[(i-n+1):i]
        xi = const_x ? x : x[(i-n+1):i]
        out[i] = cov(xi, yi) / var(xi)
    end
    return out
end

"""
```
mlr_intercept(y::AbstractVector{<:Real}; n::Int=10, x::AbstractVector{<:Real}=collect(1.0:n))::Vector{Float64}
```

Moving linear regression y-intercept
"""
function mlr_intercept(
    y::AbstractVector{<:Real};
    n::Int = 10,
    x::AbstractVector{<:Real} = collect(1.0:n),
)::Vector{Float64}
    @assert n<length(y) && n>0 "Argument n out of bounds."
    @assert length(x) == n || length(x) == length(y)
    const_x = length(x) == n
    out = zeros(length(y))
    out[1:(n-1)] .= NaN
    ybar = runmean(y, n = n, cumulative = false)
    @inbounds for i in n:length(y)
        yi = y[(i-n+1):i]
        xi = const_x ? x : x[(i-n+1):i]
        out[i] = ybar[i] - mean(xi)*(cov(xi, yi)/var(xi))
    end
    return out
end

"""
```
mlr(y::AbstractVector{<:Real}; n::Int=10)::Vector{Float64}
```

Moving linear regression predictions
"""
function mlr(y::AbstractVector{<:Real}; n::Int = 10)::Vector{Float64}
    b = mlr_beta(y, n = n)
    return b.intercept .+ b.slope .* float(n)
end

"""
```
mlr_se(y::AbstractVector{<:Real}; n::Int=10)::Vector{Float64}
```

Moving linear regression standard errors
"""
function mlr_se(y::AbstractVector{<:Real}; n::Int = 10)::Vector{Float64}
    yhat = mlr(y, n = n)
    out = zeros(length(y))
    out[1:(n-1)] .= NaN
    nf = float(n)
    @inbounds for i in n:length(y)
        r = y[(i-n+1):i] .- yhat[i]
        out[i] = sqrt(sum(r .^ 2)/nf)
    end
    return out
end

"""
```
mlr_ub(y::AbstractVector{<:Real}; n::Int=10, mult::Real=2.0)::Vector{Float64}
```

Moving linear regression upper bound, `mult` standard errors above the prediction
"""
function mlr_ub(y::AbstractVector{<:Real}; n::Int = 10, mult::Real = 2.0)::Vector{Float64}
    return mlr(y, n = n) .+ mult .* mlr_se(y, n = n)
end

"""
```
mlr_lb(y::AbstractVector{<:Real}; n::Int=10, mult::Real=2.0)::Vector{Float64}
```

Moving linear regression lower bound, `mult` standard errors below the prediction
"""
function mlr_lb(y::AbstractVector{<:Real}; n::Int = 10, mult::Real = 2.0)::Vector{Float64}
    return mlr(y, n = n) .- mult .* mlr_se(y, n = n)
end

"""
```
mlr_bands(y::AbstractVector{<:Real}; n::Int=10, mult::Real=2.0)
```

Moving linear regression bands

*Output*

A NamedTuple `(lower, mid, upper)`: the regression estimate and the bands `mult`
standard errors below and above it.
"""
function mlr_bands(y::AbstractVector{<:Real}; n::Int = 10, mult::Real = 2.0)
    mid = mlr(y, n = n)
    se = mlr_se(y, n = n)
    return (lower = mid .- mult .* se, mid = mid, upper = mid .+ mult .* se)
end

"""
```
mlr_rsq(y::AbstractVector{<:Real}; n::Int=10, adjusted::Bool=false)::Vector{Float64}
```

Moving linear regression R-squared or adjusted R-squared
"""
function mlr_rsq(
    y::AbstractVector{<:Real};
    n::Int = 10,
    adjusted::Bool = false,
)::Vector{Float64}
    yhat = mlr(y, n = n)
    rsq = runcor(y, yhat, n = n, cumulative = false) .^ 2.0
    if adjusted
        return rsq .- (1.0 .- rsq)*(1.0/(float(n) .- 2.0))
    else
        return rsq
    end
end
