# # [LinearSolve solvers](@id benchmark-LS-solvers)
# 
# In this page, we will benchmark several solvers provided by [LinearSolve.jl](https://docs.sciml.ai/LinearSolve/stable/) for solving steadystate and spectrum in hierarchical equations of motion approach.  

using LinearSolve
using BenchmarkTools
using HierarchicalEOM
HierarchicalEOM.versioninfo()

# Here, we use the example of [the single-impurity Anderson model](@ref exp-SIAM):
ϵ = -5
U = 10
Γ = 2
μ = 0
W = 10
kT = 0.5
N = 5
tier = 2
ωlist = -10:1:10

σm = sigmam()
σz = sigmaz()
II = qeye(2)
d_up = kron(σm, II)
d_dn = kron(-1 * σz, σm)
Hsys = ϵ * (d_up' * d_up + d_dn' * d_dn) + U * (d_up' * d_up * d_dn' * d_dn)

bath_up = Fermion_Lorentz_Pade(d_up, Γ, μ, W, kT, N)
bath_dn = Fermion_Lorentz_Pade(d_dn, Γ, μ, W, kT, N)
bath_list = [bath_up, bath_dn]
M_even = M_Fermion(Hsys, tier, bath_list)
M_odd = M_Fermion(Hsys, tier, bath_list, ODD)
ados_s = steadystate(M_even);

# ## LinearSolve Solver List
# (click [here](https://docs.sciml.ai/LinearSolve/stable/solvers/solvers/) to see the full solver list provided by `LinearSolve.jl`)
# ### UMFPACKFactorization (Default solver)
# This solver performs better when there is more structure to the sparsity pattern (depends on the complexity of your system and baths).
UMFPACKFactorization();

# ### KLUFactorization
# This solver performs better when there is less structure to the sparsity pattern (depends on the complexity of your system and baths).
KLUFactorization();

# ### A generic BICGSTAB implementation from Krylov
KrylovJL_BICGSTAB();

# ### Pardiso
# This solver is based on Intel openAPI Math Kernel Library (MKL) Pardiso
# !!! note "Note"
#     Using this solver requires adding the package [Pardiso.jl](https://github.com/JuliaSparse/Pardiso.jl), i.e. `using Pardiso`
using Pardiso
using LinearSolve
MKLPardisoFactorize()
MKLPardisoIterate();

# ## Solving Stationary State
# Since we are using [`BenchmarkTools`](https://juliaci.github.io/BenchmarkTools.jl/stable/) (`@benchmark`) in the following, we set `verbose = false` to disable the output message.
# ### UMFPACKFactorization (Default solver)
@benchmark steadystate(M_even; verbose = false)

# ### KLUFactorization
@benchmark steadystate(M_even; solver = KLUFactorization(), verbose = false)

# ### KrylovJL_BICGSTAB
@benchmark steadystate(M_even; solver = KrylovJL_BICGSTAB(rtol = 1e-10, atol = 1e-12), verbose = false)

# ### MKLPardisoFactorize
@benchmark steadystate(M_even; solver = MKLPardisoFactorize(), verbose = false)

# ### MKLPardisoIterate
@benchmark steadystate(M_even; solver = MKLPardisoIterate(), verbose = false)

# ## Calculate Spectrum
# ### UMFPACKFactorization (Default solver)
@benchmark DensityOfStates(M_odd, ados_s, d_up, ωlist; verbose = false)

# ### KLUFactorization
@benchmark DensityOfStates(M_odd, ados_s, d_up, ωlist; solver = KLUFactorization(), verbose = false)

# ### KrylovJL_BICGSTAB
@benchmark DensityOfStates(
    M_odd,
    ados_s,
    d_up,
    ωlist;
    solver = KrylovJL_BICGSTAB(rtol = 1e-10, atol = 1e-12),
    verbose = false,
)

# ### MKLPardisoFactorize
@benchmark DensityOfStates(M_odd, ados_s, d_up, ωlist; solver = MKLPardisoFactorize(), verbose = false)

# ### MKLPardisoIterate
@benchmark DensityOfStates(M_odd, ados_s, d_up, ωlist; solver = MKLPardisoIterate(), verbose = false)
