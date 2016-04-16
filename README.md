# COMTRADE

[![Build Status](https://travis-ci.org/tshort/COMTRADE.jl.svg?branch=master)](https://travis-ci.org/tshort/COMTRADE.jl)

This package supports reading files in COMTRADE format. 1991 and 1999 file
formats are supported. Some of the configuration features from the 2013 
version are supported, but these have not been tested.

Here are references for the COMTRADE format:

* [IEEE C37.111-1999](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=798772&filter=AND(p_Publication_Number:6491))
  *IEEE Standard Common Format for Transient Data Exchange (COMTRADE) for Power Systems*.
* [COMTRADE Brief](https://www.naspi.org/Badger/content/File/FileService.aspx?fileID=07A0DC42960E0C306958C4AEC991884C).
* R. Das, [Summary of Changes in 2013 COMTRADE Standard](http://www.pes-psrc.org/Reports/MCpresentations/Summary%20of%20Changes%20in%202013%20COMTRADE%20Standard_rev1.pdf).

The main function exported is `read_comtrade`. It takes the base file name as an
argument and returns a `ComtradeData` type. Here is an example:

```julia
julia> using COMTRADE

julia> z1 = read_comtrade("testfile");

julia> dump(z1)
COMTRADE.ComtradeData
  filename: UTF8String "testfile"
  cfg: COMTRADE.ComtradeCfg
    station_name: UTF8String "test station"
    rec_dev_id: UTF8String ""
    rev_year: Int64 1999
    tt: Int64 6
    nA: Int64 6
    nD: Int64 0
    A: DataFrames.DataFrame  6 observations of 13 variables
      An: DataArrays.DataArray{Int64,1}(6) [1,2,3,4]
      ch_id: DataArrays.DataArray{UTF8String,1}(6) UTF8String["Ia","Ib","Ic","Va"]
      ph: DataArrays.DataArray{Int64,1}(6) [NA,NA,NA,NA]
      ccbm: DataArrays.DataArray{Int64,1}(6) [NA,NA,NA,NA]
      uu: DataArrays.DataArray{UTF8String,1}(6) UTF8String["A","A","A","V"]
      a: DataArrays.DataArray{Float64,1}(6) [0.00244967114195532,0.00254256773968132,0.00230147536920041,0.219208974410077]
      b: DataArrays.DataArray{Float64,1}(6) [-124.351654052734,-111.587440490723,-112.254196166992,-11141.0302734375]
      skew: DataArrays.DataArray{Int64,1}(6) [0,0,0,0]
      min: DataArrays.DataArray{Int64,1}(6) [-124,-112,-112,-11141]
      max: DataArrays.DataArray{Int64,1}(6) [116,138,113,10341]
      primary: DataArrays.DataArray{Int64,1}(6) [1,1,1,1]
      secondary: DataArrays.DataArray{Int64,1}(6) [1,1,1,1]
      PS: DataArrays.DataArray{UTF8String,1}(6) UTF8String["P","P","P","P"]
    D: DataFrames.DataFrame  0 observations of 4 variables
      Dn: Array(Int64,(0,)) Int64[]
      ch_id: Array(Int64,(0,)) Int64[]
      ph: Array(Int64,(0,)) Int64[]
      ccbm: Array(Int64,(0,)) Int64[]
    lf: Float64 0.0
    nrates: Int64 1
    samp: Array(Float64,(1,)) [7679.73046875]
    endsamp: Array(Int64,(1,)) [1792]
    npts: Int64 1792
    time: COMTRADE.DateTimeMicro
      instant: Base.Dates.UTInstant{COMTRADE.Microsecond}
        periods: COMTRADE.Microsecond
          value: Int64 63385742626419783
    triggertime: COMTRADE.DateTimeMicro
      instant: Base.Dates.UTInstant{COMTRADE.Microsecond}
        periods: COMTRADE.Microsecond
          value: Int64 63385742626419783
    ft: ASCIIString "ASCII"
    timemult: Float64 1.0
    time_code: ASCIIString ""
    local_code: ASCIIString ""
    tmq_code: ASCIIString ""
    leapsec: Int64 0
  dat: DataFrames.DataFrame  1792 observations of 8 variables
    n: DataArrays.DataArray{Int64,1}(1792) [1,2,3,4]
    time: DataArrays.DataArray{Float64,1}(1792) [-0.108307,-0.108177,-0.10804599999999999,-0.107916]
    Ia: DataArrays.DataArray{Float64,1}(1792) [-58.72251448860902,-58.29137236762489,-55.35421666842046,-50.17316220318496]
    Ib: DataArrays.DataArray{Float64,1}(1792) [-35.239216403572314,-39.90228563814786,-46.64009014830336,-54.49916703165832]
    Ic: DataArrays.DataArray{Float64,1}(1792) [92.91082562037856,97.40100406568855,100.9406731835188,103.35952379654843]
    Va: DataArrays.DataArray{Float64,1}(1792) [-1958.3663353993743,-1443.0060365612826,-943.4287838807177,-434.2063363261095]
    Vb: DataArrays.DataArray{Float64,1}(1792) [-7580.524159010285,-7908.7284414062515,-8205.55235364517,-8505.600276516663]
    Vc: DataArrays.DataArray{Float64,1}(1792) [9760.180549944238,9607.186039520926,9419.741016960339,9216.675575853038]
  hdr: UTF8String ""
  inf: UTF8String ""
```

Access measurements by column name in the `dat` as usual with DataFrames. For 
the example above, this would be `z1.dat[:Ia]`.

The utility string macro `S_str` is also provided to make it easier to enter
DataFrame columns as symbols for column names that are not standard. An example
is `S"V(A)"`.

For storing timestamps, a `DateTimeMicro` type is provided with microsecond 
precision.

Here are some limitations in the current version:

* Writing isn't supported.
* The 2013 extensions for data in BINARY32 and FLOAT32 are not supported.
* The 2013 `CFF` extension is not supported.

None of these should be hard to add. I just haven't had the need or don't have
example files.

