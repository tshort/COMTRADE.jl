"""
    ComtradeCfg
    
`ComtradeCfg` holds information from a COMTRADE "cfg" configuration file. Fields
include:

* `station_name::UTF8String` -- Identifier for the substation name. 
* `rec_dev_id::UTF8String` -- Identifier for the recording device. 
* `rev_year::Int` -- File format revision, normally 1991, 1999, or 2013. 
* `tt::Int` -- Total number of channels. 
* `nA::Int` -- Number of analog channels.
* `nD::Int` -- Number of digital channels.
* `A::DataFrame` -- Table of analog channel information, one row per channel.
* `D::DataFrame` -- Table of digital channel information, one row per channel.
* `lf::Float64` -- Nominal line frequency in hertz. 
* `nrates::Int` -- Number of sample rates.
* `samp::Vector{Float64}` -- Sample rate in hertz. 
* `endsamp::Vector{Int}` -- Numper of sample points at each sampling rate.
* `npts::Int` -- Number of sample points. 
* `time` -- Time stamp of the first data point.
* `triggertime` -- Time stamp of the trigger time.
* `ft::ASCIIString` -- File type, options include "ASCII" or "BINARY".
* `timemult::Float64` -- Multiplication factor for the timestamp.
* `time_code::ASCIIString` -- Time difference between local time and UTC, including daylight savings (2013).
* `local_code::ASCIIString` -- Time difference between local time and UTC when time stamps are in UTC (2013).
* `tmq_code::ASCIIString` -- Time quality as defined in IEEE C37.118. F=not reliable, 4=time within 1 μs, 0=clock locked in (2013).
* `leapsec::Int` -- Leap second indicator, 0=no adjustment, 1=a leap second was added, 2=a leap second was subtracted, 3=no capability to address (2013).

`A` includes the following columns:

* `:An::Int` -- Analog channel index.
* `:ch_id::UTF8String` -- Channel identifier.
* `:ph::UTF8String` -- Channel phase identifier. 
* `:ccbm::UTF8String` -- Circuit component. 
* `:uu::UTF8String` -- Units. 
* `:a::Float64` -- Channel multiplier.
* `:b::Float64` -- Channel offset adder. 
* `:skew::Float64` -- Time skew in microseconds from the start of the sample period. 
* `:min::Float64` -- Minimum data value. 
* `:max::Float64` -- Maximum data value. 
* `:primary::Float64` -- Voltage or current transformer ratio primary factor.
* `:secondary::Float64` -- Voltage or current transformer ratio secondary factor. 
* `:PS::UTF8String` -- "P" means `ax+b` is a primary value; "S" means a secondary value.

`D` includes the following columns:

* `:Dn::Int` -- Digital channel index.
* `:ch_id::UTF8String` -- Channel identifier.
* `:ph::UTF8String` -- Channel phase identifier. 
* `:ccbm::UTF8String` -- Circuit component. 
* `:y::Int` -- Normal state, 0 or 1.

Note that the `:PS` column of `A` is not used to adjust the data in `read_comtrade`.
Likewise, `:skew` is not used to adjust the time stamp.

Some of the columns in `A` and `D` may be missing in older file revisions.
"""
type ComtradeCfg
    station_name::UTF8String
    rec_dev_id::UTF8String
    rev_year::Int
    tt::Int
    nA::Int
    nD::Int
    A::DataFrame
    D::DataFrame
    lf::Float64
    nrates::Int
    samp::Vector{Float64}
    endsamp::Vector{Int}
    npts::Int
    time
    triggertime
    ft::ASCIIString
    timemult::Float64
    time_code::ASCIIString
    local_code::ASCIIString
    tmq_code::ASCIIString
    leapsec::Int
end

ComtradeCfg() = ComtradeCfg("", "", 1991, 0, 0, 0, 
                            DataFrame(), 
                            DataFrame(Any[Int[] for i in 1:4], [:Dn, :ch_id, :ph, :ccbm]), 
                            0.0, 1, [0.0], [0], 0, 
                            DateTimeMicro(), DateTimeMicro(), "", 1.0,
                            "", "", "", 0)
asint(x) = parse(Int, x)                            
asfloat(x) = parse(Float64, x)                            

function read_cfg(fn)
    x = ComtradeCfg()
    a = readlines(fn)
    sa = split(a[1], ',')
    x.station_name = sa[1]    
    x.rec_dev_id = sa[2]
    if length(sa) > 2
        x.rev_year = asint(sa[3])
    end
    sa = split(a[2], ',')
    x.tt = asint(sa[1])
    x.nA = asint(replace(sa[2], "A", ""))
    x.nD = asint(replace(sa[3], "D", ""))
    x.A = readtable(fn, separator = ',', header = false, skipstart = 2, 
                    nrows = x.nA)
    names!(x.A, [:An, :ch_id, :ph, :ccbm, :uu, :a, :b, :skew, :min, :max, :primary, :secondary, :PS][1:ncol(x.A)])
    if x.nD > 0
        x.D = readtable(fn, separator = ',', header = false, skipstart = 2 + x.nA, 
                        nrows = x.nD)
        if x.rev_year > 1991
            names!(x.D, [:Dn, :ch_id, :ph, :ccbm, :y])
        else
            names!(x.D, [:Dn, :ch_id, :y])
        end
    end
    x.nrates  = asint(a[x.tt + 4])
    for i in 1:max(x.nrates, 1)
        sa = split(a[x.tt + 4 + i], ',')
        x.samp[i]    = asfloat(sa[1])
        x.endsamp[i] = asint(sa[2])
    end
    nrow = x.tt + max(x.nrates, 1)
    x.npts = sum(x.endsamp)    
    try
        x.time        = DateTimeMicro(strip(a[nrow + 5]))
    catch
        x.time        = strip(a[nrow + 5])
    end
    try
        x.triggertime = DateTimeMicro(strip(a[nrow + 6]))
    catch
        x.triggertime = strip(a[nrow + 6])
    end
    x.ft     = uppercase(strip(a[nrow + 7]))
    if x.rev_year >= 1999
        x.timemult = asfloat(a[nrow + 8])
    end
    if x.rev_year >= 2013
        sa = split(a[nrow + 9], ',')
        x.time_code = sa[1]
        x.local_code = strip(sa[2])
        sa = split(a[nrow + 10], ',')
        x.tmq_code = sa[1]
        x.leapsec = asint(sa[2])
    end
    return x
end    