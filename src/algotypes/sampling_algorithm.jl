# This file is a part of BAT.jl, licensed under the MIT License (MIT).


const AnyNSamples = Union{
    Integer,
    Tuple{Integer,Integer},
}


"""
    BAT.AbstractSamplingAlgorithm

Abstract type for BAT sampling algorithms. See [`bat_sample`](@ref).
"""
abstract type AbstractSamplingAlgorithm end


"""
    bat_sample(
        [rng::AbstractRNG],
        posterior::BAT.AnyPosterior,
        n::BAT.AnyNSamples,
        [algorithm::BAT.AbstractSamplingAlgorithm]
    )::DensitySampleVector

Draw `n` samples from `posterior`.

Returns a NamedTuple of the shape

```julia
(result = X::DensitySampleVector, ...)
```

Result properties not listed here are algorithm-specific and are not part
of the stable BAT API.


`posterior` may be a

* [`BAT.AbstractPosteriorDensity`](@ref)

* [`BAT.DistLikeDensity`](@ref)

* [`BAT.DensitySampleVector`](@ref)

* `Distributions.MultivariateDistribution`

Depending on the type of posterior, `n` may be of type

* `Integer`: Number of samples

* `Tuple{Integer,Integer}`: Tuple of number of samples per sample source
   and number of sample sources (e.g. number of MCMC chains). The total number
   of samples is `product(n)`.

Depending on the type of `posterior`, the number of samples returned may be
somewhat larger or smaller than specified by `product(n)`.

Also depending on the `posterior` type, the samples may be independent or
correlated (e.g. when using MCMC).
"""
function bat_sample end
export bat_sample


@inline function bat_sample(target::AnyPosterior, n::AnyNSamples; kwargs...)
    rng = bat_default_withinfo(bat_sample, Val(:rng), target)
    algorithm = bat_default_withinfo(bat_sample, Val(:algorithm), target)
    r = bat_sample(rng, target, n, algorithm; kwargs...)
    result_with_args(r, (rng = rng, algorithm = algorithm), kwargs)
end


@inline function bat_sample(target::AnyPosterior, n::AnyNSamples, algorithm::AbstractSamplingAlgorithm; kwargs...)
    rng = bat_default_withinfo(bat_sample, Val(:rng), target)
    r = bat_sample(rng, target, n, algorithm; kwargs...)
    result_with_args(r, (rng = rng, algorithm = algorithm), kwargs)
end


@inline function bat_sample(rng::AbstractRNG, target::AnyPosterior, n::AnyNSamples; kwargs...)
    algorithm = bat_default_withinfo(bat_sample, Val(:algorithm), target)
    r = bat_sample(rng, target, n, algorithm; kwargs...)
    result_with_args(r, (rng = rng, algorithm = algorithm), kwargs)
end


function argchoice_msg(::typeof(bat_sample), ::Val{:rng}, x::AbstractRNG)
    "Initializing new RNG of type $(typeof(x))"
end

function argchoice_msg(::typeof(bat_sample), ::Val{:algorithm}, x::AbstractSamplingAlgorithm)
    "Using sampling algorithm $x"
end