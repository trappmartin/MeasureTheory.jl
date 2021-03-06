module MeasureTheory

using MLStyle
import Distributions
using Reexport
using SimplePosets

import Distributions
const Dists = Distributions
# include("traits.jl")

const EmptyNamedTuple = NamedTuple{(),Tuple{}}


export ≪

abstract type AbstractMeasure{X} end

"""
    logdensity(μ::Measure{X}, x::X)

Compute the logdensity of the measure μ at the point x. This is the standard way
to define `logdensity` for a new measure. the base measure is implicit here, and
is understood to be `baseMeasure(μ)`.

Methods for computing density relative to other measures will be 
"""
function logdensity end


Base.eltype(μ::AbstractMeasure{X}) where {X} = X



logdensity(μ::Dists.Distribution, x) = Dists.logpdf(μ,x)

density(μ::Dists.Distribution, x) = Dists.pdf(μ,x)



# # This lets us write e.g.
# # @measure Normal 
# # making it easier to declare a new measure.
export @measure

"""
    @measure μ base

Create a new measure named `μ` with base measure `b`. 
For example, `@measure Normal Lebesgue` is equivalent to

    struct Normal{P, X} <: AbstractMeasure{X}
        par::P
        Normal(nt::NamedTuple) = new{typeof(nt), eltype(Normal, typeof(nt))}(nt)
    end

    Normal(; kwargs...) = Normal((;kwargs...))
"""
macro measure(d,b)
    d = esc(d)
    b = esc(b)
    return quote
        struct $d{P,X} <: AbstractMeasure{X}
            par :: P    
        end

        function $d(nt::NamedTuple)
            P = typeof(nt)
            return $d{P, eltype($d{P})}
        end

        $d(;kwargs...) = $d((;kwargs...))

        baseMeasure(μ::$d{P,X}) where {P,X} = $b{X}

        ≪(::$d{P,X}, ::$b{X}) where {P,X} = true
    end    
end

include("basemeasures.jl")
include("absolutecontinuity.jl")
include("basemeasures/lebesgue.jl")
include("combinators/scale.jl")
include("combinators/superpose.jl")
include("combinators/product.jl")
include("distributions.jl")
include("probability/normal.jl")
include("density.jl")



end # module
