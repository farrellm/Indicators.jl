using Indicators
using Test
using Random
using Statistics

const global N = 252
const global X0 = 50.0
const global SEED = 1

# Every column of an indicator's output has length N and is not entirely NaN
valid(v::AbstractVector) = length(v) == N && !all(isnan, v)
valid(nt::NamedTuple) = all(valid, values(nt))

TEST_FILES = [
    "util.jl",
    "run.jl",
    "ma.jl",
    "mom.jl",
    "vol.jl",
    "reg.jl",
    "patterns.jl",
    "chaos.jl",
    "trendy.jl",
    "bugfixes.jl",
    "tables.jl",  # loads Tables, so it must come last
]

@inbounds for testfile in TEST_FILES
    include(testfile)
end

# JET can lag pre-release Julia; the checks are the same on every
# released version, so skipping them there loses nothing.
if isempty(VERSION.prerelease)
    include("jet.jl")
end
