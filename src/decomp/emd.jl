import Dierckx #for cubic spline interplation

function findLocalMaxima(signal::Vector; angle=0.0, includeEdge=:false)::Tuple{Array{Int64,1},Array{Float64,1}}
  Inds = Int64[]
  signal = real.(exp(-1im*angle)*signal)
  if includeEdge #include maxima on edges
    if length(signal)>1
      if signal[1]>signal[2]
        push!(Inds,1)
      end
      for i=2:length(signal)-1
        if signal[i-1]<signal[i]>signal[i+1]
          push!(Inds,i)
        end
      end
      if signal[end]>signal[end-1]
        push!(Inds,length(signal))
      end
    end
  else #ignore maxima on edges
    for i=2:length(signal)-1
      if signal[i-1]<signal[i]>signal[i+1]
        push!(Inds,i)
      end
    end
  end
  Vals = [ signal[idx[1]] for idx in Inds]
  return IndsVals = (Inds, Vals)
end

function SIFT(r::Vector{Float64}; siftStopThresh=1e-6, includeEdge=:true)
#References: Huang, Norden E., et al. "The empirical mode decomposition and the Hilbert spectrum for nonlinear and non-stationary time series analysis." Proceedings of the Royal Society of London. Series A: mathematical, physical and engineering sciences 454.1971 (1998): 903-995.
  L = length(r)
  eStart = round(Int,L/4); eStop = round(Int,3L/4); eL = length(eStart:eStop)
  while true
    maxIndsVals = findLocalMaxima(r, includeEdge=includeEdge)
    if length(maxIndsVals[1]) < 4; break; end
    maxInterpolator = Dierckx.Spline1D(maxIndsVals[1], maxIndsVals[2])
    u = maxInterpolator(1:L)
    minIndsVals = findLocalMaxima(-r, includeEdge=includeEdge)
    if length(minIndsVals[1]) < 4; break; end
    minInterpolator = Dierckx.Spline1D(minIndsVals[1], -minIndsVals[2])
    l = minInterpolator(1:L)
    e = (u+l)./2
    r -= e
    mav = sum(abs,e[eStart:eStop])/eL
    if mav < siftStopThresh; break; end
  return r
  end
end

function EMD(x::Vector{Float64}; emdStopThresh = 1e-2, siftStopThresh = 1e-6, includeEdge = :true)::Array{Vector{Float64},1}
#References: Huang, Norden E., et al. "The empirical mode decomposition and the Hilbert spectrum for nonlinear and non-stationary time series analysis." Proceedings of the Royal Society of London. Series A: mathematical, physical and engineering sciences 454.1971 (1998): 903-995.
  IMF = Vector{Float64}[]
  L = length(x); M = maximum(abs.(x))
  eStart = round(Int,L/4); eStop = round(Int,3L/4); eL = length(eStart:eStop)
  while true
    φ = SIFT(x, siftStopThresh=siftStopThresh, includeEdge=includeEdge)
    if isnothing(φ); break; end
    if maximum(abs.(φ)) > 3M; break; end
    x -= φ
    push!(IMF, φ)
    mav = sum(abs,x[eStart:eStop])/eL
    if mav < emdStopThresh; break; end
  end
  return push!(IMF, x)
end

function ℂSIFT(r::Vector{ComplexF64}; D = 4, siftStopThresh = 1e-3, includeEdge = :true)
#References: Rilling, Gabriel, et al. "Bivariate empirical mode decomposition." IEEE signal processing letters 14.12 (2007): 936-939.
  L = length(r)
  eStart = round(Int,L/4); eStop = round(Int,3L/4); eL = length(eStart:eStop)
  err = false
  while true
    e = zeros(ComplexF64,L)
    for d in 1:2D
      ϑ = 2π*(d-1)/2D
      maxIndsVals = findLocalMaxima(r, angle=ϑ, includeEdge=includeEdge)
      if length(maxIndsVals[1]) < 4; err = true; break; end
      maxInterpolator = Dierckx.Spline1D(maxIndsVals[1], maxIndsVals[2])
      e += exp(1im*ϑ)*maxInterpolator(1:L)
    end
    if err; break; end
    e /= 2D
    r -= e
    mav = sum(abs,e[eStart:eStop])/eL
    if mav < siftStopThresh; break; end
  end
  return r
end

function ℂEMD(z::Vector{ComplexF64}; emdStopThresh=1e-2, D=4, siftStopThresh=1e-3, includeEdge=:true)::Array{Vector{ComplexF64},1}
#References: Rilling, Gabriel, et al. "Bivariate empirical mode decomposition." IEEE signal processing letters 14.12 (2007): 936-939.
  IMF = Vector{ComplexF64}[]
  L = length(z); M = maximum(abs.(z))
  eStart = round(Int,L/4); eStop = round(Int,3L/4); eL = length(eStart:eStop)
  while true
    φ = ℂSIFT(z, D=D, siftStopThresh=siftStopThresh, includeEdge=includeEdge)
    if maximum(abs.(φ)) > 3M; break; end
    z -= φ
    push!(IMF, φ)
    mav = sum(abs,z[eStart:eStop])/eL
    if mav < emdStopThresh; break; end
  end
  return push!(IMF, z)
end
