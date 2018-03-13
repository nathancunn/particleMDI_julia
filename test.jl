include("smc.jl")

# An example use of pMDImodel
# Takes arguments
# data - the datafiles, specified in a Matrix of data arrays
# dataTypes - a concatenation of the data type structs (only gaussianCluster now)
# C - the maximum number of clusters to be fit
# N - the number of particles
# s - a fixed cluster allocation for the fixed proportion of data
# ρ - the proportion fo data to be fixed
# nThreads
# fullOutput
# essThreshold
## Generate some data for testing
n_obs = Int64(150)
K = 2
d     = [rand(2:5) for k = 1:K]
dataTypes = [gaussianCluster for k = 1:K]
data      = [[randn(Int64(n_obs * 0.5), d[k]) - 3; randn(Int64(n_obs * 0.5), d[k]) + 3] for k = 1:K]
s = [repeat(1:2, inner = Int(n_obs * 0.5)) for k = 1:K]
model, smcio = pMDImodel(data, dataTypes, 3, 32, s, 0.25, 4, false, 0.5)
@time smc!(model, smcio)


# Using the iris data
using RDatasets
K = 1
data = [Matrix(dataset("datasets", "iris")[:, 1:4])]
dataTypes = [gaussianCluster]
s = [repeat(1:3,  inner = 50)]
particles = 32
nComponents = 10
nThreads = 4
essThreshold = 2.0
n_obs = size(data[1])[1]
model = pMDImodel(data, dataTypes, nComponents, particles, s, 0.05, nThreads, true, essThreshold)
smcio = SMCIO{model.particle, model.pScratch}(particles, n_obs, nThreads, true, essThreshold)

@time smc!(model, smcio)

print([smcio.allZetas[i - 1][smcio.allAs[i - 1][1]].c for i = length(smcio.allAs):1])
print([smcio.allZetas[i][32].c for i = 2:length(smcio.allZetas)])

print([smcio.allAs[i - 1][1] for i = 2:length(smcio.allZetas)])

a = [smcio.allZetas[p][1] for p = 1:length(smcio.allZetas)]
test = [a[i].clusters[1].c for i = 1:length(a)]



inds = Array{Int64}(150)
for j = 1:150
    i = 151 - j
    if j == 1
        #inds[i] = smcio.allZetas[i][1].c[1]
        inds[i] = 30

    else
        inds[i] = smcio.allAs[i][inds[i + 1]]
        #inds[i] = smcio.allZetas[i][current].c[1]
    end
end


for (i, j) in enumerate(["A", "B"])
    print(i)

end

for i  = 1:length(a)
    a[i].c = [s[1][i]]
end
@time csmc!(model, smcio, a, a)
print([a[i].c for i = 1:length(a)])
