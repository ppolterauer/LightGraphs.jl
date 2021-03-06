"""
    struct MinimalDominatingSet <: DominatingSet

A struct representing an algorithm to calculate the minimum [dominating set](https://en.wikipedia.org/wiki/Dominating_set)
of a graph.

### Optional Arguments
- `rng<:AbstractRNG`: override default random number generator (`GLOBAL_RNG`).

### Performance
Runtime: ``\\mathcal{O}(|V|+|E|)``
Memory: ``\\mathcal{O}(|V|)``
"""
struct MinimalDominatingSet{R<:AbstractRNG} <: DominatingSet
    rng::R
end
MinimalDominatingSet(;rng=GLOBAL_RNG) = MinimalDominatingSet(rng)


function dominating_set(g::AbstractGraph{T}, alg::MinimalDominatingSet) where {T<:Integer}
    nvg = nv(g)
    in_dom_set = trues(nvg)
    length_ds = Int(nvg)
    dom_degree = degree(g)
    @inbounds @simd for v in vertices(g)
        dom_degree[v] -= (has_edge(g, v, v) ? 1 : 0)
    end

    for v in randperm(alg.rng, nvg)
    	(dom_degree[v] == 0) && continue # v is not adjacent to any dominating vertex
    	# Check if any vertex is depending on v to be dominated
        dependent = findfirst(u -> !in_dom_set[u] && dom_degree[u] <= 1, neighbors(g, v))

        (dependent != nothing) && continue
        in_dom_set[v] = false
        length_ds -= 1
        dom_degree[neighbors(g, v)] .-= 1
    end

    return LightGraphs.findall!(in_dom_set, Vector{T}(undef, length_ds))
end
