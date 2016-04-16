module COMTRADE

## TODO
## - plotting example
## - convert ascii DF columns to Array, not DataArray


using DataFrames

export read_comtrade, @S_str

# package code goes here
include("datetime.jl")
include("cfg.jl")
include("main.jl")

end # module
