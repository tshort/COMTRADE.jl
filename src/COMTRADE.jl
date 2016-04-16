module COMTRADE

## TODO
## - tests
## - plotting example


using DataFrames

export read_comtrade, @S_str

# package code goes here
include("datetime.jl")
include("cfg.jl")
include("main.jl")

end # module
