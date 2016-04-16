using COMTRADE
using Base.Test


z1 = read_comtrade("data/1991-ascii-sel")
z2 = read_comtrade("data/1999-ascii-pq")
z3 = read_comtrade("data/1999-binary-hif-sel")

@test z1.filename == "data/1991-ascii-sel"
@test z1.cfg.rev_year == 1991
@test z1.cfg.nA == 24
@test z1.cfg.A[2, :ch_id] == "IB"
@test z1.cfg.D[2, :ch_id] == "TRP"
@test z1.cfg.triggertime > z1.cfg.time
@test z1.dat[1, :IA] ≈ -270.999876
@test !z1.dat[1, :TRP]

@test z2.filename == "data/1999-ascii-pq"
@test z2.cfg.rev_year == 1999
@test z2.cfg.nA == 6
@test z2.cfg.A[2, :ch_id] == "Ib"
@test z2.cfg.triggertime > z1.cfg.time
@test z2.dat[1, :Ia] ≈ 101.06138883816476

@test z3.filename == "data/1999-binary-hif-sel"
@test z3.cfg.rev_year == 1999
@test z3.cfg.nA == 18
@test z3.cfg.A[2, :ch_id] == "IBRMS"
@test z3.cfg.D[2, :ch_id] == "NTUNE_A"
@test z3.cfg.triggertime > z1.cfg.time
@test z3.dat[1, :IARMS] ≈ 0.0
@test z3.dat[1, :EN] 


