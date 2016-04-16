
using Base.Dates
import Base.Dates.value
import Base.Dates.days

# Define a date-time with microsecond accuracy.
# Note that this doesn't include all features of a `DateTime`.
# Includes code derived from Julia base/dates/*.

immutable Microsecond <: Base.Dates.TimePeriod
    value::Int64
end

Dates.slotparse(slot::Dates.Slot{Microsecond}, x, locale) = 
    !ismatch(r"[^0-9\s]",x) ? slot.parser(Base.parse(Float64,"."*x)*1e6) : throw(SLOTERROR)
# Dates.slotformat(slot::Slot{Microsecond},dt,locale) = rpad(string(microsecond(dt)/1000.0)[3:end], slot.width, "0")
Dates.SLOT_RULE['z'] = Microsecond
Dates.periodisless(x::Microsecond,y::Microsecond) = value(x) < value(y)
Dates.periodisless(::Microsecond,::Hour)   = true
Dates.periodisless(::Microsecond,::Minute) = true
Dates.periodisless(::Microsecond,::Second) = true
Dates.periodisless(::Microsecond,::Millisecond) = true
Dates.periodisless(::Period,::Microsecond) = false
Dates.coarserperiod(::Type{Microsecond}) = (Millisecond, 1000)
Dates.toms(c::Microsecond) = div(value(c), 1000)
Dates.days(c::Microsecond) = div(value(c), 86_400_000_000)

# DateTime is a millisecond precision UTInstant interpreted by ISOCalendar
immutable DateTimeMicro <: TimeType
    instant::Dates.UTInstant{Microsecond}
    DateTimeMicro(instant::Dates.UTInstant{Microsecond}) = new(instant)
end

microsecond(dt::DateTimeMicro) = mod(value(dt),1000000)

Dates.days(dt::DateTimeMicro) = fld(value(dt),86400000000)
Dates.hour(dt::DateTimeMicro)   = mod(fld(value(dt),3600000000),24)
Dates.minute(dt::DateTimeMicro) = mod(fld(value(dt),60000000),60)
Dates.second(dt::DateTimeMicro) = mod(fld(value(dt),1000000),60)

function Base.string(dt::DateTimeMicro)
    y,m,d = yearmonthday(days(dt))
    h,mi,s = hour(dt),minute(dt),second(dt)
    yy = y < 0 ? @sprintf("%05i",y) : lpad(y,4,"0")
    mm = lpad(m,2,"0")
    dd = lpad(d,2,"0")
    hh = lpad(h,2,"0")
    mii = lpad(mi,2,"0")
    ss = lpad(s,2,"0")
    μs = microsecond(dt) == 0 ? "" : string(microsecond(dt)/1e6)[2:end]
    return "$yy-$mm-$(dd)T$hh:$mii:$ss$(μs)"
end
Base.show(io::IO,x::DateTimeMicro) = print(io,string(x))

DateTimeMicro(x::Int64) = DateTimeMicro(Dates.UTInstant(Microsecond(x)))

_c(x) = convert(Int64,x)
DateTimeMicro(y,m=1,d=1,h=0,mi=0,s=0,μs=0) = DateTimeMicro(_c(y),_c(m),_c(d),_c(h),_c(mi),_c(s),_c(μs))

"""
    DateTimeMicro(y, [m, d, h, mi, s, μs]) -> DateTimeMicro
Construct a `DateTimeMicro` type by parts. Arguments must be convertible to `Int64`.
"""
function DateTimeMicro(y::Int64=1,m::Int64=1,d::Int64=1,
                       h::Int64=0,mi::Int64=0,s::Int64=0,μs::Int64=0)
    0 < m < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    0 < d < daysinmonth(y,m)+1 || throw(ArgumentError("Day: $d out of range (1:$(daysinmonth(y,m)))"))
    -1 < h < 24 || throw(ArgumentError("Hour: $h out of range (0:23)"))
    -1 < mi < 60 || throw(ArgumentError("Minute: $mi out of range (0:59)"))
    -1 < s < 60 || throw(ArgumentError("Second: $s out of range (0:59)"))
    -1 < μs < 1000000 || throw(ArgumentError("Millisecond: $μs out of range (0:999999)"))
    rata = μs + 1000000*(s + 60mi + 3600h + 86400 * Dates.totaldays(y,m,d))
    return DateTimeMicro(Dates.UTInstant(Microsecond(rata)))
end
# Convenience constructors from Periods
function DateTimeMicro(y::Year,m::Month=Month(1),d::Day=Day(1),
                       h::Hour=Hour(0),mi::Minute=Minute(0),
                       s::Second=Second(0),μs::Microsecond=Microsecond(0))
    return DateTimeMicro(value(y),value(m),value(d),
                         value(h),value(mi),value(s),value(μs))
end

DateTimeMicro(dt::AbstractString,format::AbstractString;locale::AbstractString="english") = DateTimeMicro(dt,DateFormat(format,locale))
DateTimeMicro(dt::AbstractString,df::DateFormat=DateFormat("m/d/y,H:M:S.z")) = DateTimeMicro(Dates.parse(dt,df)...)

Base.convert(::Type{DateTimeMicro},dt::DateTime) = 
    DateTimeMicro(Dates.UTInstant(Microsecond(value(dt) * 1000)))
Base.convert(::Type{DateTime},dt::DateTimeMicro) = 
    DateTime(Dates.UTInstant(Millisecond(div(value(dt), 1000))))
Base.promote_rule(::Type{DateTime},x::Type{DateTimeMicro}) = DateTimeMicro
Base.isless(x::DateTimeMicro,y::DateTimeMicro) = isless(value(x),value(y))



