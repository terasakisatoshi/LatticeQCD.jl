# - - parameters - - - - - - - - - - - 
system["saveU_dir"] = ""
system["verboselevel"] = 2
system["L"] = (4, 4, 4, 4)
system["Nwing"] = 1
system["Nsteps"] = 2
system["quench"] = false
system["logfile"] = "HMC_L04040404_beta5.7_Staggered_mass0.5.txt"
system["initial"] = "hot"
system["Dirac_operator"] = "Staggered"
system["log_dir"] = "./logs"
system["Nthermalization"] = 0
system["update_method"] = "HMC"
system["randomseed"] = 111
system["NC"] = 3
system["BoundaryCondition"] = [1, 1, 1, -1]
system["saveU_format"] = nothing
system["β"] = 5.7
actions["use_autogeneratedstaples"] = false
actions["couplingcoeff"] = Any[]
actions["couplinglist"] = Any[]
md["Δτ"] = 0.1
md["N_SextonWeingargten"] = 2
md["SextonWeingargten"] = false
md["MDsteps"] = 10
cg["eps"] = 1.0e-19
cg["MaxCGstep"] = 3000
staggered["Nf"] = 4
staggered["mass"] = 0.5
measurement["measurement_methods"] = Dict[Dict{Any,Any}("eps" => 1.0e-19,"fermiontype" => "Staggered","Nf" => 4,"mass" => 0.5,"measure_every" => 50,"MaxCGstep" => 3000,"methodname" => "Chiral_condensate"), Dict{Any,Any}("fermiontype" => nothing,"measure_every" => 1,"methodname" => "Polyakov_loop"), Dict{Any,Any}("fermiontype" => nothing,"numflow" => 10,"measure_every" => 50,"methodname" => "Topological_charge"), Dict{Any,Any}("eps" => 1.0e-19,"fermiontype" => "Wilson","r" => 1,"measure_every" => 50,"hop" => 0.141139,"methodname" => "Pion_correlator","MaxCGstep" => 3000), Dict{Any,Any}("fermiontype" => nothing,"measure_every" => 1,"methodname" => "Plaquette")]
measurement["measurement_dir"] = "HMC_L04040404_beta5.7_Staggered_mass0.5"
measurement["measurement_basedir"] = "./measurements"
# - - - - - - - - - - - - - - - - - - -
