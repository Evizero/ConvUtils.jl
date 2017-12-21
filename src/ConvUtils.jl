module ConvUtils

using Images
using MosaicViews
using MappedArrays
using MLDataUtils

const DEFAULT_COLORNEG = RGB(0.230, 0.299, 0.754)
const DEFAULT_COLORZRO = RGB(0.95,  0.95,  0.95)
const DEFAULT_COLORPOS = RGB(0.706, 0.016, 0.150)

export

    falsecolor,
    upscale,
    immosaic

function falsecolor(A::Array{T,N};
                    symmetric = true,
                    colorneg  = DEFAULT_COLORNEG,
                    colorzero = DEFAULT_COLORZRO,
                    colorpos  = DEFAULT_COLORPOS) where {T<:Number,N}
    mi, ma = extrema(A)
    val = max(abs(mi), ma)
    ss = if symmetric
        scalesigned(-val, T(0), val)
    else
        scalesigned(mi, T(0), ma)
    end
    x = ss(one(T))
    cs = colorsigned(map(c->convert(RGB{typeof(x)},c), (colorneg, colorzero, colorpos))...)
    mappedarray(c->cs(ss(c)), A)
end

falsecolor(A; kw...) = falsecolor(Array(A); kw...)

function upscale(A::AbstractArray{T,N}, val::Int) where {T,N}
    repeat(A, inner=(val, val, ntuple(i->1, N-2)...))
end

function immosaic(A::AbstractArray, fill=RGB(1.,1.,1.); rep=1, npad=5, ncol=-1, nrow=-1)
    if ndims(A) == 3 && ncol == -1 && nrow == -1
        ncol = max(ceil(Int,sqrt(size(A,3))), 5)
    end
    mosaicview(upscale(A, rep), fill; npad=npad, nrow=nrow, ncol=ncol, rowmajor=true)
end

end # module
