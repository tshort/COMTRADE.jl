"""
    ComtradeData
    
`ComtradeData` holds data and configuration information from a set of COMTRADE 
files. Fields include:

* `filename::UTF8String` -- Base file name (without extension). 
* `cfg::ComtradeCfg` -- Configuration information.
* `dat::DataFrame` -- Table of results with each channel as a column.
* `hdr::UTF8String` -- Contents of the "hdr" file.
* `inf::UTF8String` -- Contents of the "inf" file.
"""
type ComtradeData
    filename::UTF8String
    cfg::ComtradeCfg
    dat::DataFrame
    hdr::UTF8String
    inf::UTF8String
end

function addcol!(d::DataFrame, x)
    push!(d.columns, x)
    push!(DataFrames.index(d), symbol(string("x", ncol(d) + 1)))
    d
end

"""
    read_comtrade(basename)
    
Read contents of a set of COMTRADE files with base file name `basename` (no 
extension).

Returns a `COMTRADE.ComtradeData` with the following fields: 

* `filename::UTF8String` -- Base file name (without extension). 
* `cfg::ComtradeCfg` -- Configuration information.
* `dat::DataFrame` -- Table of results with each channel as a column.
* `hdr::UTF8String` -- Contents of the "hdr" file.
* `inf::UTF8String` -- Contents of the "inf" file.

See also `COMTRADE.ComtradeCfg` for a description of the `cfg` field.
"""
function read_comtrade(basename)
    cfg = read_cfg("$basename.cfg")
    if cfg.ft == "ASCII"
        d = readtable("$basename.dat", separator = ',', header = false)
        for i in (1:cfg.nD) + 2 + cfg.nA
            d[i] = map(Bool, d[i])
        end
    elseif cfg.ft == "BINARY"
        x = reinterpret(Int16, readbytes(open("$basename.dat")))
        n = cfg.nA + div(cfg.nD, 16) + 2 + 2
        x = reshape(x[1:(n * cfg.npts)], (n, cfg.npts))
        global d = DataFrame()
        addcol!(d, reinterpret(UInt32, x[1:2, :], (cfg.npts,)))
        addcol!(d, reinterpret(UInt32, x[3:4, :], (cfg.npts,)))
        for i = 1:cfg.nA
            addcol!(d, reshape(x[i+4, :], (cfg.npts,)))
        end
        for i = 1:cfg.nD
            addcol!(d, Bool[(x >>> (mod1(i, 16) - 1)) & 0x01 for x in x[cfg.nA + 4 + cld(i, 16), :]])
            # addcol!(d, Bool[(x >>> (16 - mod1(i, 16))) & 0x01 for x in x[cfg.nA + 4 + cld(i, 16), :]])
        end
    else
        error("Unsupported data type $(x.ft)")
    end
    newnames = DataFrames.make_unique(vcat(:n, :time, Symbol[symbol(x) for x in vcat(cfg.A[:ch_id], cfg.D[:ch_id])]))
    names!(d, newnames)
    # analog multipliers
    for i in 1:cfg.nA
        d.columns[i+2] = cfg.A[i,:a] * d[i+2] + cfg.A[i,:b]
    end
    # analog multipliers
    d.columns[2] = 1e-6 * cfg.timemult * d[2]
    hdr = isreadable("$basename.hdr") ? readall("$basename.hdr") : ""
    inf = isreadable("$basename.inf") ? readall("$basename.inf") : ""
    return ComtradeData(basename, cfg, d, hdr, inf)
end

"""
    S"some name"

Returns a symbol. Equivalent to `symbol("some name")`. This helps when COMTRADE
data columns use nonstandard names.    
"""
macro S_str(arg)
    Meta.quot(symbol(arg))
end


