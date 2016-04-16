# Example plotting using PyPlot

using COMTRADE
using Glob
using PyCall
@pyimport matplotlib.backends.backend_pdf as pdf
using PyPlot 

# Plot the first six analog channels in each of the test data files
function process_files()
    p = pdf.PdfPages("waves.pdf")
    ioff()
    for fn in glob("../test/data/*.cfg")
        println(fn)
        fn = replace(fn, ".cfg", "")
        z = read_comtrade(fn)
        f, ax = subplots(6, 1, sharex = true, figsize = [12, 12])
        nm = names(z.dat)
        for i in 1:6
            ax[i,1][:plot](z.dat[:time], z.dat[i+2])
            ax[i,1][:set_ylabel](z.cfg.A[i, :ch_id])
        end
        ax[1,1][:set_title](fn)
        p[:savefig]()
    end 
    p[:close]()
    ion()
end

process_files() 