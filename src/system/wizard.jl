module Wizard
using REPL.TerminalMenus
using TOML
import ..System_parameters: Params_set, print_parameters, Params
import ..Parameter_structs:
    System,
    Action,
    CG_params_interactive,
    Quench_parameters,
    Fermion_parameters,
    Wilson_parameters,
    Staggered_parameters,
    Stout_parameters,
    kindsof_loops,
    Stout_parameters_interactive,
    ConjugateGradient,
    NoSmearing_parameters,
    Domainwall_parameters,
    MD,
    MD_interactive,
    Measurement_parameters,
    Plaq_parameters_interactive,
    Poly_parameters_interactive,
    ChiralCondensate_parameters_interactive,
    TopologicalCharge_parameters_interactive,
    staggered_wizard,
    wilson_wizard,
    Domainwall_wizard,
    Pion_parameters_interactive,
    Measurement_parameterset,
    generate_printable_parameters,
    remove_default_values!,
    struct2dict

@enum Wizardmode simple = 1 expert = 2
@enum Initialconf coldstart = 1 hotstart = 2 filestart = 3 instantonstart = 4
@enum Fileformat JLD = 1 ILDG = 2 BridgeText = 3 Nosave = 0
@enum SmearingMethod Nosmearing = 1 STOUT = 2
@enum Fermiontype Nofermion = 1 Wilsonfermion = 2 Staggeredfermion = 3 Domainwallfermion = 4
@enum Options Plaquette = 1 Polyakov_loop = 2 Topological_charge = 3 Chiral_condensate = 4 Pion_correlator =
    5




function get_filename_extension(loadtype::Fileformat)
    if loadtype == JLD
        ext = ".jld"
    elseif loadtype == ILDG
        ext = ".ildg"
    elseif v == BridgeText
        ext = ".txt"
    else
        error("error!")
    end
    return ext

end


function print_wizard_logo(outs)
    blue = "\033[34m"
    red = "\033[31m"
    green = "\033[32m"
    magenta = "\033[35m"
    normal = "\033[0m\033[0m"

    logo = raw"""
--------------------------------------------------------------------------------  
run_wizard       
　　　　　格　　　　　　　格　　　　　　　
　　　　　色　　　　　　　格　　　　
　　　　色色色　　　　　　格　　　
　子子色色色色色子子子子子格子子子子
　　　　色色色　　　　　　格　　　　
　　　　　色　　　　　　　格　　　
　　　　　格　　　　　　　格　　　
　　　　　力　　　　　　　学　　　　　　LatticeQCD.jl
　　　　力力力　　　　　学学学　　　
　子子力力力力力子子子学学学学学子子　　
　　　　力力力　　　　　学学学　　　　　
　　　　　力　　　　　　　学　　　　　　
　　　　　格　　　　　　　格　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
    """


    logo = replace(logo, "Q" => "$(red)Q$(normal)")
    logo = replace(logo, "C" => "$(blue)C$(normal)")
    logo = replace(logo, "D" => "$(green)D$(normal)")
    logo = replace(logo, "色" => "$(red)色$(normal)")
    logo = replace(logo, "力" => "$(blue)力$(normal)")
    logo = replace(logo, "学" => "$(green)学$(normal)")

    println(outs, logo)
    println(
        outs,
        "Welcome to a wizard for Lattice QCD.\n",
        "We'll get you set up simulation parameters in no time.",
    )
    println(
        "--------------------------------------------------------------------------------",
    )
    println("If you leave the prompt empty, a default value will be used.")
    println("To exit, press Ctrl + c.")
end


function run_wizard()
    print_wizard_logo(stdout)

    system = System()
    action = Action()
    println(system)
    println(action)


    mode =
        request(
            "Choose wizard mode",
            Wizardmode |> instances |> collect .|> string |> RadioMenu,
        ) |> Wizardmode
    isexpert::Bool = (mode == expert)

    filename = Base.prompt(
        "put the name of the parameter file you make",
        default = "my_parameters.jl",
    )

    system.L = set_Lattice_size(isexpert)
    system.NC = set_gaugegroup(isexpert)
    system.β = set_β(system.NC)


    if isexpert
        system.randomseed = parse(Int64, Base.prompt("Input random seed.", default = "111"))
        system.verboselevel = set_verboselevel()
    end


    if check_isfileloading()
        system.loadU_format, _ = set_loadU_format()
        system.update_method = "Fileloading"
        system.loadU_dir = String(Base.prompt("Loading directory", default = "./confs"))

        filelist = request(
            "Which configurations do you use?",
            RadioMenu([
                "All configurations in the directory",
                "Configurations written in a list",
            ]),
        )

        if filelist == 1
            system.loadU_fromfile = false
        else
            system.loadU_fromfile = true
            system.loadU_filename = String(
                Base.prompt(
                    "name of the list in $(system.loadU_dir)",
                    default = "filelist.txt",
                ),
            )
        end
    else

        if system.NC == 2
            initialconf =
                request(
                    "Choose initial configurations",
                    RadioMenu([
                        "cold start",
                        "hot start",
                        "start from a file",
                        "start from one instanton (Radius is half of Nx)",
                    ]),
                ) |> Initialconf
        else
            initialconf =
                request(
                    "Choose initial configurations",
                    RadioMenu(["cold start", "hot start", "start from a file"]),
                ) |> Initialconf
        end


        if initialconf == coldstart
            system.initial = "cold"
        elseif initialconf == hotstart
            system.initial = "hot"
        elseif initialconf == filestart
            println("Initial configuration is loaded from a file")
            system.loadU_format, filetype = set_loadU_format()
            extstring = get_filename_extension(filetype)

            system.initial = String(
                Base.prompt(
                    "Input the file name that you want to use",
                    default = "./confs/conf_00000001.$(extstring)",
                ),
            )
            system.initialtrj =
                parse(Int64, Base.prompt("Start trj number?", default = "1"))
        elseif initialconf == instantonstart
            system.initial = "one instanton"
        end

        if isexpert
            ftype =
                request(
                    "Choose a dynamical fermion",
                    RadioMenu([
                        "Nothing (quenched approximation)",
                        "Wilson Fermion (2-flavor)",
                        "Staggered Fermion",
                        "Domain-wall Fermion (DO NOT USE IT! test mode.)",
                    ]),
                ) |> Fermiontype


            if ftype == Nofermion
                cg = ConjugateGradient()
                fermion_parameters = Quench_parameters()
                system.Dirac_operator = "nothing"
                system.quench = true
            elseif ftype == Wilsonfermion
                system.quench = false
                wtype = request(
                    "Choose Wilson fermion type",
                    RadioMenu([
                        "Standard Wilson fermion action",
                        "Wilson+Clover fermion action",
                    ]),
                )
                if wtype == 1
                    println("Standard Wilson fermion action will be used")
                    system.Dirac_operator = "Wilson"
                else
                    println("Wilson+Clover fermion action will be used")
                    system.Dirac_operator = "WilsonClover"
                end
                fermion_parameters, cg = wilson_wizard()
            elseif ftype == Staggeredfermion
                system.quench = false
                system.Dirac_operator = "Staggered"
                fermion_parameters, cg = staggered_wizard()

            elseif ftype == Domainwallfermion
                system.quench = false
                system.Dirac_operator = "Domainwall"
                fermion_parameters, cg = Domainwall_wizard()
            end


        else
            system.Dirac_operator = "Wilson"
            system.quench = false
            fermion_parameters, cg = wilson_wizard_simple()
        end

        if system.quench == false
            smearingmethod =
                request(
                    "Choose a configuration format for loading",
                    RadioMenu(["No smearing", "stout smearing"]),
                ) |> SmearingMethod

            if smearingmethod == Nosmearing
                system.smearing_for_fermion = "nothing"
                smearing = NoSmearing_parameters()

            elseif smearingmethod == STOUT
                system.smearing_for_fermion = "stout"
                smearing = Stout_parameters_interactive()
                system.stout_ρ = smearing.ρ
                system.stout_loops = smearing.stout_loops
                system.stout_numlayers = smearing.numlayers
            end
        else
            smearing = NoSmearing_parameters()
        end


        if isexpert
            if system.quench
                methodtype = request(
                    "Choose an update method",
                    RadioMenu(["Heatbath", "Hybrid Monte Carlo"]),
                )
                if methodtype == 1
                    system.update_method = "Heatbath"
                    or = request("Use overrelazation method?", RadioMenu(["true", "false"]))
                    system.useOR = ifelse(or == 1, true, false)
                    if system.useOR
                        system.numOR = parse(
                            Int64,
                            Base.prompt(
                                "How many times do you want to do the OR?",
                                default = "3",
                            ),
                        )
                    end
                else
                    methodtype == 2
                    system.update_method = "HMC"
                end
            else
                methodtype = request(
                    "Choose an update method",
                    RadioMenu([
                        "Hybrid Monte Carlo",
                        "Self-learning Hybrid Monte Carlo (SLHMC)",
                    ]),
                )

                if methodtype == 1
                    system.update_method = "HMC"
                else
                    methodtype == 2
                    system.update_method = "SLHMC"
                    system.βeff = parse(
                        Float64,
                        Base.prompt("Input initial effective β", default = "$β"),
                    )
                    system.firstlearn = parse(
                        Int64,
                        Base.prompt(
                            "When do you want to start updating the effective action?",
                            default = "10",
                        ),
                    )
                end

            end
        else
            system.update_method = "HMC"
        end

        if isexpert
            Nthermalization = parse(
                Int64,
                Base.prompt(
                    "Input the number of thermalization steps (no mearurement)",
                    default = "0",
                ),
            )
            if Nthermalization < 0
                error(
                    "Invalid value for Nthermalization=$Nthermalization. This has to be positive/zero.",
                )
            end
            system.Nthermalization = Nthermalization
        end

        Nsteps = parse(
            Int64,
            Base.prompt(
                "Input the number of total trajectories after the thermalization",
                default = "$(100+system.initialtrj)",
            ),
        )
        if Nsteps <= 0
            error("Invalid value for Nsteps=$Nsteps. This has to be strictly positive.")
        end

        if isexpert
            md = MD_interactive(Dirac_operator = system.Dirac_operator)
        else
            md = MD()
        end

    end

    measurement = Measurement_parameterset()

    measurementmenu = MultiSelectMenu(Options |> instances |> collect .|> string)

    if isexpert
        choices =
            request("Select the measurement methods you want to do:", measurementmenu) |>
            collect .|>
            Options
    else
        choices = [1, 2, 5] .|> Options
    end
    nummeasurements = length(choices)
    measurement.measurement_methods = Vector{Measurement_parameters}(undef, nummeasurements)

    #@enum Options Plaquette=1 Polyakov_loop=2 Topological_charge=3 Chiral_condensate=4 Pion_correlator=5
    count = 0
    for method in choices
        count += 1
        if method == Plaquette
            measurement.measurement_methods[count] = Plaq_parameters_interactive() #plaq_wizard()
        elseif method == Polyakov_loop
            measurement.measurement_methods[count] = Poly_parameters_interactive()
        elseif method == Topological_charge
            measurement.measurement_methods[count] =
                TopologicalCharge_parameters_interactive()
        elseif method == Chiral_condensate
            measurement.measurement_methods[count] =
                ChiralCondensate_parameters_interactive()
        elseif method == Pion_correlator
            measurement.measurement_methods[count] = Pion_parameters_interactive()
        end
    end


    headername = make_headername(system, fermion_parameters)


    if nummeasurements != 0
        measurement.measurement_basedir = String(
            Base.prompt("base directory for measurements", default = "./measurements"),
        )
        measurement.measurement_dir = String(
            Base.prompt(
                "directory for measurements in $(measurement.measurement_basedir)/",
                default = headername,
            ),
        )
    end

    system.log_dir = String(Base.prompt("log directory", default = "./logs"))
    system.logfile = String(Base.prompt("logfile name", default = headername * ".txt"))


    if isexpert
        savetype =
            request(
                "Choose a configuration format for saving",
                RadioMenu(["no save", "JLD", "ILDG", "Text format (BridgeText)"]),
            ) |> x -> x - 1 |> Fileformat

        if savetype == Nosave
            system.saveU_format = "nothing"
        elseif savetype == JLD
            system.saveU_format = "JLD"
        elseif savetype == ILDG
            system.saveU_format = "ILDG"
        elseif savetype == BridgeText
            system.saveU_format = "BridgeText"
        end

        if system.saveU_format .≠ "nothing"

            system.saveU_every = parse(
                Int64,
                Base.prompt(
                    "How often do you save a configuration in file (Save every)?",
                    default = "10",
                ),
            )
            #system["saveU_basedir"] = String(Base.prompt("base directory for saving configuration", default="./confs"))
            system.saveU_dir =
                String(Base.prompt("Saving directory", default = "./confs_$(headername)"))
            #system["saveU_dir"] = system["saveU_basedir"]*"/"*system["saveU_dir"]
        end
    end

    physical, fermions, control, hmc = generate_printable_parameters(system)
    
    system_parameters_dict = Dict()

    system_parameters_dict["Physical setting"] = struct2dict(physical)
    system_parameters_dict["Physical setting(fermions)"] =
        merge(struct2dict(fermions), struct2dict(fermion_parameters))
    system_parameters_dict["System Control"] = struct2dict(control)
    system_parameters_dict["HMC related"] = struct2dict(hmc)
    system_parameters_dict["Measurement set"] =struct2dict(measurement) 



    remove_default_values!(system_parameters_dict)

    open("parametertest.toml", "w") do io
        TOML.print(io, system_parameters_dict)
    end

    #system_parameters_dict["Measurement set"]

    error("err")




    test = struct2dict(system)

    open("parametertest.toml", "w") do io
        TOML.print(io, params)
    end

    display(params)


    error("err")



    set_measurementmethods!(system, measurement, staggered, wilson, options, isexpert)

    headername = make_headername(system, staggered, wilson)

    set_measurementdir!(measurement, headername)
    set_logdir!(system, headername)
    set_saveU!(system, headername, isexpert)

    params_set = Params_set(system, actions, md, cg, wilson, staggered, measurement)


    print_parameters(filename, params_set)

    #p = Params(params_set)

    println("""
    --------------------------------------------------------------------------------  
    run_wizard is done. 
    
    The returned value in this run_wizard() is params_set.
    If you want to run a simulation in REPL or other Julia codes,  just do

    run_LQCD(params_set)

    or 

    run_LQCD("$filename")

    The output parameter file is $filename. 
    If you want to run a simulation, just do

    julia run.jl $filename

    --------------------------------------------------------------------------------  
    """)

    return params_set
end

function wilson_wizard_simple()
    wtype = 1
    println("Standard Wilson fermion action will be used")
    hop = parse(Float64, Base.prompt("Input the hopping parameter κ", default = "0.141139"))
    if hop <= 0
        error("Invalid value for κ=$hop. This has to be strictly positive.")
    end

    fermion_parameters = Wilson_parameters()
    fermion_parameters.hop = hop
    cg = ConjugateGradient()
    return fermion_parameters, cg

end



function set_verboselevel!(system)
    verboselevel = parse(Int64, Base.prompt("verbose level ?", default = "2"))

    if 1 ≤ verboselevel ≤ 3
        println("verbose level = ", verboselevel)
    else
        error("verbose level should be 1 ≤ verboselevel ≤ 3")
    end
    system.verboselevel = verboselevel
    #system["verboselevel"] = verboselevel
end

function set_verboselevel()
    verboselevel = parse(Int64, Base.prompt("verbose level ?", default = "2"))

    if 1 ≤ verboselevel ≤ 3
        println("verbose level = ", verboselevel)
    else
        error("verbose level should be 1 ≤ verboselevel ≤ 3")
    end
    return verboselevel
    #system["verboselevel"] = verboselevel
end


function set_Lattice_size(isexpert)
    if isexpert
        println("Input Lattice size, L=(Nx,Ny,Nz,Nt)")
        NX = parse(Int64, Base.prompt("Nx ?", default = "4"))
        NY = parse(Int64, Base.prompt("Ny ?", default = "4"))
        NZ = parse(Int64, Base.prompt("Nz ?", default = "4"))
        NT = parse(Int64, Base.prompt("Nt ?", default = "4"))
        #NT = parse(Int64,readline(stdin))
        L = [NX, NY, NZ, NT]
        #L = (NX, NY, NZ, NT)
        #system["L"] = L
        if (NX <= 0) | (NY <= 0) | (NZ <= 0) | (NT <= 0)
            error("Invalid parameter L=$L, elements must be positive integers")
        end
    else
        NX = parse(Int64, Base.prompt("Input spatial lattice size ", default = "4"))
        NT = parse(Int64, Base.prompt("Input temporal lattice size ", default = "4"))
        #L = (NX, NX, NX, NT)
        L = [NX, NX, NX, NT]
        #system["L"] = L
        if (NX <= 0) | (NT <= 0)
            error("Invalid parameter L=$L, elements must be positive integers")
        end
    end
    println("Lattice is $L")
    return L
end

function set_gaugegroup(isexpert)
    if isexpert
        SNC = request("Choose a gauge group", RadioMenu(["SU(3)", "SU(2)"]))
        NC = ifelse(SNC == 1, 3, 2)
    else
        NC = 3
    end
    println("SU($NC) will be used")
    return NC
end


function set_β(NC)
    if NC == 3
        β = parse(Float64, Base.prompt("β ?", default = "5.7"))
    elseif NC == 2
        β = parse(Float64, Base.prompt("β ?", default = "2.7"))
    end
    @assert β > 0 "Invalid value for β=$β. This has to be positive or zero"
    return β
end


function check_isfileloading()
    fileloading = request(
        "Do you perform only measurements on configurations in a directory? (no update)",
        RadioMenu(["No", "Yes"]),
    )
    if fileloading == 2
        isfileloading = true
    else
        isfileloading = false
    end
    return isfileloading
end

function set_loadU_format()
    loadtype =
        request(
            "Choose a configuration format for loading",
            RadioMenu(["JLD", "ILDG", "Text format(BridgeText)"]),
        ) |> Fileformat

    if loadtype == JLD
        loadU_format = "JLD"
    elseif loadtype == ILDG
        loadU_format = "ILDG"
    elseif v == BridgeText
        loadU_format = "BridgeText"
    end

    return loadU_format, loadtype
end


function make_headername(system, fermion_parameters)
    L = system.L
    headername =
        system.update_method *
        "_L" *
        string(L[1], pad = 2) *
        string(L[2], pad = 2) *
        string(L[3], pad = 2) *
        string(L[4], pad = 2) *
        "_beta" *
        string(system.β)

    if system.update_method == "HMC"
        if system.quench == true
            headername *= "_quenched"
        else
            headername *= "_" * system.Dirac_operator
            if system.Dirac_operator == "Staggered"
                headername *=
                    "_mass" * string(staggered.mass) * "_Nf" * string(staggered.Nf)
            elseif system.Dirac_operator == "Wilson" ||
                   system.Dirac_operator == "WilsonClover"
                headername *= "_kappa" * string(fermion_parameters.hop)
            end
        end
    elseif system.update_method == "Heatbath"
        headername *= "_quenched"
    else
        if system.Dirac_operator != nothing
            headername *= "_" * system.Dirac_operator
            if system.Dirac_operator == "Staggered"
                headername *=
                    "_mass" *
                    string(fermion_parameters.mass) *
                    "_Nf" *
                    string(fermion_parameters.Nf)
            elseif system.Dirac_operator == "Wilson" ||
                   system.Dirac_operator == "WilsonClover"
                headername *= "_kappa" * string(fermion_parameters.hop)
            end
        else
        end
    end
    return headername
end

end

#using .Wizard
#Wizard.run_wizard()
