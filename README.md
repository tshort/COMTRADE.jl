# COMTRADE

[![Build Status](https://travis-ci.org/tshort/COMTRADE.jl.svg?branch=master)](https://travis-ci.org/tshort/COMTRADE.jl)

This package supports reading files in COMTRADE format (Common format for
Transient Data Exchange for power systems). 1991 and 1999 file formats are
supported. Some of the configuration features from the 2013 version are
supported, but these have not been tested.

Here are references for the COMTRADE format:

* [IEEE C37.111-1999](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=798772&filter=AND(p_Publication_Number:6491))
  *IEEE Standard Common Format for Transient Data Exchange (COMTRADE) for Power Systems*.
* [COMTRADE Brief](https://www.naspi.org/Badger/content/File/FileService.aspx?fileID=07A0DC42960E0C306958C4AEC991884C).
* R. Das, [Summary of Changes in 2013 COMTRADE Standard](http://www.pes-psrc.org/Reports/MCpresentations/Summary%20of%20Changes%20in%202013%20COMTRADE%20Standard_rev1.pdf).

The main function exported is `read_comtrade`. It takes the base file name as an
argument and returns a `ComtradeData` type. Here is an example:

```julia
julia> using COMTRADE

julia> z1 = read_comtrade("test/data/1999-ascii-pq");

julia> dump(z1)
COMTRADE.ComtradeData
  filename: UTF8String "test/data/1999-ascii-pq"
  cfg: COMTRADE.ComtradeCfg
    station_name: UTF8String "Sub1"
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
      a: DataArrays.DataArray{Float64,1}(6) [0.00618221921336894,0.00488201670743981,0.00430520193917411,0.231206244021046]
      b: DataArrays.DataArray{Float64,1}(6) [-317.518127441406,-210.759567260742,-207.621368408203,-11241.396484375]
      skew: DataArrays.DataArray{Int64,1}(6) [0,0,0,0]
      min: DataArrays.DataArray{Int64,1}(6) [-318,-211,-208,-11241]
      max: DataArrays.DataArray{Int64,1}(6) [288,268,214,11417]
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
    samp: Array(Float64,(1,)) [7678.4833984375]
    endsamp: Array(Int64,(1,)) [3584]
    npts: Int64 3584
    time: COMTRADE.DateTimeMicro
      instant: Base.Dates.UTInstant{COMTRADE.Microsecond}
        periods: COMTRADE.Microsecond
          value: Int64 63487961061051022
    triggertime: COMTRADE.DateTimeMicro
      instant: Base.Dates.UTInstant{COMTRADE.Microsecond}
        periods: COMTRADE.Microsecond
          value: Int64 63487961061051022
    ft: ASCIIString "ASCII"
    timemult: Float64 1.0
    time_code: ASCIIString ""
    local_code: ASCIIString ""
    tmq_code: ASCIIString ""
    leapsec: Int64 0
  dat: DataFrames.DataFrame  3584 observations of 8 variables
    n: Array(Int64,(3584,)) [1,2,3,4,5,6,7,8,9,10  …  3575,3576,3577,3578,3579,3580,3581,3582,3583,3584]
    time: Array(Float64,(3584,)) [-0.041663,-0.041533,-0.041403,-0.041273,-0.041142,-0.041012,-0.040882,-0.040752,-0.040621,-0.040491  …  0.423793,0.423923,0.424054,0.424184,0.424314,0.424444,0.424575,0.424705,0.424835,0.424965]
    Ia: Array(Float64,(3584,)) [101.061,93.9024,87.003,78.249,70.8242,62.0701,54.1074,43.2329,35.5422,25.7249  …  269.502,264.995,258.893,255.444,249.076,242.183,233.429,228.65,217.776,207.964]
    Ib: Array(Float64,(3584,)) [-151.76,-151.829,-152.971,-153.44,-152.166,-150.691,-151.697,-150.96,-148.475,-146.258  …  -151.829,-148.607,-147.869,-143.71,-142.699,-138.877,-137.534,-133.438,-129.611,-125.588]
    Ic: Array(Float64,(3584,)) [76.367,80.4053,90.1049,99.0597,105.255,113.271,119.131,125.997,134.349,137.514  …  -116.17,-114.013,-110.716,-106.673,-101.692,-97.5847,-91.3895,-83.5756,-78.1209,-68.559]
    Va: Array(Float64,(3584,)) [2112.15,1575.06,1015.77,445.848,-109.741,-679.895,-1257.22,-1809.11,-2353.6,-2868.96  …  7203.08,6720.55,6223.69,5704.63,5167.31,4630.22,4092.9,3559.5,3025.88,2510.52]
    Vb: Array(Float64,(3584,)) [-10306.7,-10153.2,-9995.9,-9809.54,-9579.07,-9330.59,-9030.6,-8698.06,-8332.5,-7926.52  …  -6946.67,-6913.88,-6884.55,-6870.0,-6862.61,-6873.7,-6891.94,-6902.8,-6921.04,-6906.49]
    Vc: Array(Float64,(3584,)) [8381.56,8746.67,9086.43,9422.53,9747.39,10046.9,10346.4,10594.7,10810.3,10993.0  …  -602.716,-201.016,222.637,708.493,1216.04,1749.2,2271.38,2812.12,3345.29,3849.17]
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

