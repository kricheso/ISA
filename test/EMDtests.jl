using ISA, Plots

sig = cos.(0.0:π/100:10pi) +  cos.( 5*(0.0:π/100:10pi))+  cos.( 20*(0.0:π/100:10pi))
φ₁ = SIFT(sig)
plot(sig)
plot!(φ₁)
φ₂ = SIFT(sig-φ₁)
plot!(φ₂)
plot!(sig-φ₁-φ₂)


#-------------------------------------------

sig = cos.(0.0:π/100:10pi) +  cos.( 5*(0.0:π/100:10pi))+  cos.( 20*(0.0:π/100:10pi))
IMF = EMD(sig)
plot(sig)
plot!(IMF)

#-------------------------------------------

sig = exp.( 1im*(0.0:π/100:10pi)) +  exp.( 5im*(0.0:π/100:10pi)) +  exp.( 20im*(0.0:π/100:10pi))
φ₁ = ℂSIFT(sig)
plot(real(sig))
plot!(real(φ₁))
φ₂ = ℂSIFT(sig-φ₁)
plot!(real(φ₂))
plot!(real(sig-φ₁-φ₂))

#-------------------------------------------

sig = exp.( 1im*(0.0:π/100:10pi)) +  exp.( 5im*(0.0:π/100:10pi)) +  exp.( 20im*(0.0:π/100:10pi))
IMF = ℂEMD(sig)
plot(real(sig))
plot!(real.(IMF))
