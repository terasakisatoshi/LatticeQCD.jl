module Demo
using Dates
using Plots
using TOML
#using LaTeXStrings

##import ..System_parameters: Params_set, parameterloading
#import ..LTK_universe: Universe
#import ..MD: construct_MD_parameters
#import ..Measurements: Measurement_set, measurements
#import ..Verbose_print: println_verbose1, println_verbose2, Verbose_1
#import ..Heatbath: heatbath!
import ..Universe_module: Univ
import ..Transform_oldinputfile: transform_to_toml
import ..Parameters_TOML: construct_Params_from_TOML
import ..AbstractUpdate_module: Updatemethod, update!
import Gaugefields: Gradientflow, println_verbose_level1, get_myrank,flow!,
save_binarydata,save_textdata,saveU
import ..AbstractMeasurement_module:Measurement_methods,
calc_measurement_values,measure,Plaquette_measurement,get_temporary_gaugefields
using Gaugefields
using InteractiveUtils
using Dates
using Random
import ..Simpleprint:println_rank0
import ..AbstractMeasurement_module:Plaquette_measurement,Polyakov_measurement




system = Dict()
actions = Dict()
md = Dict()
cg = Dict()
wilson = Dict()
staggered = Dict()
measurement = Dict()
# - - parameters - - - - - - - - - - - 
# - - parameters - - - - - - - - - - - 
system["saveU_dir"] = ""
system["verboselevel"] = 1
#system["L"] = (6, 6, 6, 6)
system["L"] = (4, 4, 4, 4)
system["Nwing"] = 1
system["Nsteps"] = 10000
system["quench"] = true
system["logfile"] = "Heatbath_L06060606_beta8.0_quenched.txt"
system["initial"] = "hot"
system["Dirac_operator"] = nothing
system["log_dir"] = "./logs"
system["Nthermalization"] = 10
system["update_method"] = "Heatbath"
system["randomseed"] = 111
system["NC"] = 3
system["saveU_every"] = 1
system["BoundaryCondition"] = [1, 1, 1, -1]
system["saveU_format"] = nothing
#system["β"] = 6.93015
system["β"] = 6.75850661032668353
actions["use_autogeneratedstaples"] = false
actions["couplingcoeff"] = Any[]
actions["couplinglist"] = Any[]
md["Δτ"] = 0.05
md["SextonWeingargten"] = false
md["MDsteps"] = 20
cg["eps"] = 1.0e-19
cg["MaxCGstep"] = 3000
wilson["Clover_coefficient"] = 0
wilson["r"] = 1
wilson["hop"] = 0
staggered["Nf"] = 0
staggered["mass"] = 0
measurement["measurement_methods"] = Dict[
    Dict{Any,Any}(
        "fermiontype" => nothing,
        "measure_every" => 1,
        "methodname" => "Polyakov_loop",
    ),
    Dict{Any,Any}(
        "fermiontype" => nothing,
        "measure_every" => 1,
        "methodname" => "Plaquette",
    ),
]
measurement["measurement_dir"] = "Heatbath_L06060606_beta8.0_quenched"
measurement["measurement_basedir"] = "./measurements"
# - - - - - - - - - - - - - - - - - - -

data = """
["HMC related"]
"Δτ" = 0.05
MDsteps = 20

["Physical setting(fermions)"]
Dirac_operator = "nothing"

["Physical setting"]
initial = "hot"
L = [4, 4, 4, 4]
Nthermalization = 10
update_method = "Heatbath"
Nwing = 1
Nsteps = 10000
"β" = 6.758506610326683

["System Control"]
logfile = "Heatbath_L06060606_beta8.0_quenched.txt"
measurement_dir = "Heatbath_L06060606_beta8.0_quenched"
measurement_basedir = "./measurements"
log_dir = "./logs"
hasgradientflow = false

["Measurement set".measurement_methods.Polyakov_loop]
measure_every = 1
methodname = "Polyakov_loop"

["Measurement set".measurement_methods.Plaquette]
measure_every = 1
methodname = "Plaquette"

[gradientflow_measurements.measurements_for_flow]
       """


function demo()
    filename = "./demoparam.toml"
    parameters = construct_Params_from_TOML(TOML.parse(data))
    Random.seed!(parameters.randomseed)
    univ = Univ(parameters)

    run_demo!(parameters, univ)

    return

    numaccepts = 0
    for itrj = parameters.initialtrj:parameters.Nsteps
        #println_verbose_level1(univ.U[1], "# itrj = $itrj")
        @time accepted = update!(updatemethod, univ.U)
        if accepted
            numaccepts +=1
        end
        #save_gaugefield(savedata,univ.U,itrj)
        measure(plaq_m, itrj, univ.U; additional_string = "")
        measure(poly_m, itrj, univ.U; additional_string = "")

        #calc_measurement_values(measurements,itrj, univ.U)


        Usmr = deepcopy(univ.U)
        for istep = 1:numflow
            τ = istep * dτ
            flow!(Usmr, gradientflow)
            additional_string = "$istep $τ "
            for i =1:measurements_for_flow.num_measurements
                interval = measurements_for_flow.intervals[i]
                if istep % interval == 0
                    measure(measurements_for_flow.measurements[i], itrj, Usmr, additional_string = additional_string)
                end
            end
        end

        println_verbose_level1(
        univ.U[1],"Acceptance $numaccepts/$itrj : $(round(numaccepts*100/itrj)) %")


    end


end

function demo_old()

    params_set = Params_set(system, actions, md, cg, wilson, staggered, measurement)

    parameters = parameterloading(params_set)
    univ = Universe(parameters)

    mdparams = construct_MD_parameters(parameters)

    meas = Measurement_set(
        univ,
        parameters.measuredir,
        measurement_methods = parameters.measurement_methods,
    )
    run_demo!(parameters, univ, meas)

end

function run_demo_old!(parameters, univ, meas)
    plt1 = histogram([0], label = nothing) #plot1
    plt2 = plot([], [], label = nothing) #plot2
    ylabel!("Plaquette")
    xlabel!("MC time")
    plt3 = histogram([0], label = nothing) #plot3
    plt4 = plot([], [], label = nothing) #plot4
    ylabel!("|Polyakov loop|")
    xlabel!("MC time")
    plt5 = scatter([], [], label = nothing, title = "Polyakov loop") #plot5 scatter
    ylabel!("Im")
    xlabel!("Re")
    plt6 = plot([], [], label = nothing) #plot6
    ylabel!("Arg(Polyakov loop)")
    xlabel!("MC time")
    plot(plt1, plt2, plt3, plt4, plt5, plt6, layout = 6)

    hist_plaq = []
    hist_poly = []
    hist_poly_θ = []

    function plot_refresh!(
        plt1,
        plt2,
        plt3,
        plt4,
        plt5,
        plt6,
        hist_plaq,
        hist_poly,
        hist_poly_θ,
        plaq,
        poly,
        itrj,
    )
        bins = round(Int, log(itrj) * 4 + 1)
        if itrj < 500
            bins = round(Int, log(itrj) * 1.5 + 1)
        elseif itrj < 1000
            bins = round(Int, log(itrj) * 2.5 + 1)
        elseif itrj < 2000
            bins = round(Int, log(itrj) * 3.5 + 1)
        end
        append!(hist_plaq, plaq)
        append!(hist_poly, abs(poly))
        # omit un-thermalized part
        if (10 < itrj < 1000) & (itrj % 5 == 0)
            print("remove unthermalize part $(length(hist_plaq)) -> ")
            popfirst!(hist_plaq)
            popfirst!(hist_poly)
            println(" $(length(hist_plaq))")
        end
        #
        plt1 = histogram(hist_plaq, bins = bins, label = nothing) #plot1
        #plot!(plt1,title="SU(3), Quenched, L=6^4,")
        plot!(plt1, title = "SU(3), Quenched, L=4^4,")
        xlabel!("Plaquette")
        plot!(plt2, title = "Heatbath")
        plt3 = histogram(hist_poly, bins = bins, label = nothing) #plot3
        xlabel!("|Polyakov loop|")
        #
        if itrj < 500
            push!(plt2, 1, itrj, plaq)
        elseif 500 < itrj < 1000
            if itrj % 2 == 0
                push!(plt2, 1, itrj, plaq)
            end
        elseif 1000 < itrj
            if itrj % 5 == 0
                push!(plt2, 1, itrj, plaq)
            end
        end
        push!(plt4, 1, itrj, abs(poly))
        if itrj < 500
            push!(plt5, 1, real(poly), imag(poly))
        end
        if 500 < itrj < 1000
            if itrj % 10 == 0
                push!(plt5, 1, real(poly), imag(poly))
            end
        end
        if 1000 < itrj
            if itrj % 50 == 0
                push!(plt5, 1, real(poly), imag(poly))
            end
        end
        #
        push!(plt6, 1, itrj, angle(poly))
        #
        plot(plt1, plt2, plt3, plt4, plt5, plt6, layout = 6)
        gui()
    end


    @assert parameters.update_method == "Heatbath"
    verbose = Verbose_1()
    Nsteps = parameters.Nsteps
    numaccepts = 0
    plaq, poly = measurements(0, univ.U, univ, meas; verbose = verbose) # check consistency of preparation.

    for itrj = 1:Nsteps
        @time heatbath!(univ)

        plaq, poly = measurements(itrj, univ.U, univ, meas; verbose = verbose)
        plot_refresh!(
            plt1,
            plt2,
            plt3,
            plt4,
            plt5,
            plt6,
            hist_plaq,
            hist_poly,
            hist_poly_θ,
            plaq,
            poly,
            itrj,
        )

        println_verbose1(verbose, "-------------------------------------")
        #println("-------------------------------------")
        flush(stdout)
        flush(verbose)
    end
end


function run_demo!(parameters, univ)

    println_verbose_level1(
        univ.U[1],
        "# ", pwd()
    )
    println_verbose_level1(
        univ.U[1],"# ", Dates.now()
    )
    io = IOBuffer()
    InteractiveUtils.versioninfo(io)
    versioninfo = String(take!(io))
    println_verbose_level1(
        univ.U[1],versioninfo
    )

    updatemethod = Updatemethod(parameters,univ)

    eps_flow = parameters.eps_flow 
    numflow = parameters.numflow
    Nflow = parameters.Nflow
    dτ = Nflow * eps_flow
    gradientflow = Gradientflow(univ.U, Nflow = 1, eps = eps_flow)  

    measurements = Measurement_methods(univ.U, parameters.measuredir, parameters.measurement_methods)
    i_plaq = 0
    for i = 1:measurements.num_measurements
        if typeof(measurements.measurements[i]) == Plaquette_measurement
            i_plaq = i
            plaq_m = measurements.measurements[i]
        end
    end
    if i_plaq == 0
        plaq_m = Plaquette_measurement(univ.U,printvalues=false)
    end

    plaq_m = Plaquette_measurement(univ.U,printvalues=false)
    poly_m =  Polyakov_measurement(univ.U,printvalues=false)

    measurements_for_flow = Measurement_methods(univ.U, parameters.measuredir, parameters.measurements_for_flow)


    numaccepts = 0


    plt1 = histogram([0], label = nothing) #plot1
    plt2 = plot([], [], label = nothing) #plot2
    ylabel!("Plaquette")
    xlabel!("MC time")
    plt3 = histogram([0], label = nothing) #plot3
    plt4 = plot([], [], label = nothing) #plot4
    ylabel!("|Polyakov loop|")
    xlabel!("MC time")
    plt5 = scatter([], [], label = nothing, title = "Polyakov loop") #plot5 scatter
    ylabel!("Im")
    xlabel!("Re")
    plt6 = plot([], [], label = nothing) #plot6
    ylabel!("Arg(Polyakov loop)")
    xlabel!("MC time")
    plot(plt1, plt2, plt3, plt4, plt5, plt6, layout = 6)

    hist_plaq = []
    hist_poly = []
    hist_poly_θ = []

    function plot_refresh!(
        plt1,
        plt2,
        plt3,
        plt4,
        plt5,
        plt6,
        hist_plaq,
        hist_poly,
        hist_poly_θ,
        plaq,
        poly,
        itrj,
    )
        bins = round(Int, log(itrj) * 4 + 1)
        if itrj < 500
            bins = round(Int, log(itrj) * 1.5 + 1)
        elseif itrj < 1000
            bins = round(Int, log(itrj) * 2.5 + 1)
        elseif itrj < 2000
            bins = round(Int, log(itrj) * 3.5 + 1)
        end
        append!(hist_plaq, plaq)
        append!(hist_poly, abs(poly))
        # omit un-thermalized part
        if (10 < itrj < 1000) & (itrj % 5 == 0)
            print("remove unthermalize part $(length(hist_plaq)) -> ")
            popfirst!(hist_plaq)
            popfirst!(hist_poly)
            println(" $(length(hist_plaq))")
        end
        #
        plt1 = histogram(hist_plaq, bins = bins, label = nothing) #plot1
        #plot!(plt1,title="SU(3), Quenched, L=6^4,")
        plot!(plt1, title = "SU(3), Quenched, L=4^4,")
        xlabel!("Plaquette")
        plot!(plt2, title = "Heatbath")
        plt3 = histogram(hist_poly, bins = bins, label = nothing) #plot3
        xlabel!("|Polyakov loop|")
        #
        if itrj < 500
            push!(plt2, 1, itrj, plaq)
        elseif 500 < itrj < 1000
            if itrj % 2 == 0
                push!(plt2, 1, itrj, plaq)
            end
        elseif 1000 < itrj
            if itrj % 5 == 0
                push!(plt2, 1, itrj, plaq)
            end
        end
        push!(plt4, 1, itrj, abs(poly))
        if itrj < 500
            push!(plt5, 1, real(poly), imag(poly))
        end
        if 500 < itrj < 1000
            if itrj % 10 == 0
                push!(plt5, 1, real(poly), imag(poly))
            end
        end
        if 1000 < itrj
            if itrj % 50 == 0
                push!(plt5, 1, real(poly), imag(poly))
            end
        end
        #
        push!(plt6, 1, itrj, angle(poly))
        #
        plot(plt1, plt2, plt3, plt4, plt5, plt6, layout = 6)
        gui()
    end


    #@assert parameters.update_method == "Heatbath"
    #verbose = Verbose_1()
    #Nsteps = parameters.Nsteps
    numaccepts = 0
    #plaq, poly = measurements(0, univ.U, univ, meas; verbose = verbose) # check consistency of preparation.

    plaq = measure(plaq_m, 0, univ.U; additional_string = "")
    poly = measure(poly_m, 0, univ.U; additional_string = "")

    for itrj = 1:parameters.initialtrj:parameters.Nsteps
        #@time heatbath!(univ)
        @time update!(updatemethod, univ.U)
        plaq = measure(plaq_m, itrj, univ.U; additional_string = "")
        poly = measure(poly_m, itrj, univ.U; additional_string = "")
        
        #plaq, poly = measurements(itrj, univ.U, univ, meas; verbose = verbose)
        plot_refresh!(
            plt1,
            plt2,
            plt3,
            plt4,
            plt5,
            plt6,
            hist_plaq,
            hist_poly,
            hist_poly_θ,
            plaq,
            poly,
            itrj,
        )

        #println_verbose1(verbose, "-------------------------------------")
        #println("-------------------------------------")
        flush(stdout)
        #flush(verbose)
    end
end

end
