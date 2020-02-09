using ISA

t = Array(0.0:0.005:2.0)

using Interact
@manipulate for a= 0:0.05:1, ω = -5:0.1:20, φ = -pi:pi/50:pi, t₀ = 0:0.1:2, σₜ=0.05:0.01:0.7, ωᵣ = -10:0.1:10
    a₀(t) = a .* exp(-1/2*((t-t₀)/σₜ)^2)
    ω₀(t) = ω + ωᵣ*t
    φ₀ = φ
    𝐶₀ = Tuple([a₀,ω₀,φ₀])

    isaPlot3d(𝐶₀, t)
end
