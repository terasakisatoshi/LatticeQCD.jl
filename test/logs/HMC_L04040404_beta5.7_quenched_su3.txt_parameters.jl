# - - parameters - - - - - - - - - - - 
system["saveU_dir"] = ""
system["verboselevel"] = 2
system["L"] = (4, 4, 4, 4)
system["Nwing"] = 1
system["Nsteps"] = 5
system["quench"] = true
system["logfile"] = "HMC_L04040404_beta5.7_quenched_su3.txt"
system["initial"] = "cold"
system["Dirac_operator"] = nothing
system["log_dir"] = "./logs"
system["Nthermalization"] = 0
system["update_method"] = "HMC"
system["randomseed"] = 111
system["NC"] = 3
system["saveU_every"] = 1
system["BoundaryCondition"] = [1, 1, 1, -1]
system["saveU_format"] = nothing
system["β"] = 5.7
actions["use_autogeneratedstaples"] = false
actions["couplingcoeff"] = Any[]
actions["couplinglist"] = Any[]
md["Δτ"] = 0.06666666666666667
md["N_SextonWeingargten"] = 2
md["SextonWeingargten"] = false
md["MDsteps"] = 15
cg["eps"] = 1.0e-19
cg["MaxCGstep"] = 3000
wilson["Clover_coefficient"] = 0
wilson["r"] = 1
wilson["hop"] = 0
staggered["Nf"] = 0
staggered["mass"] = 0
measurement["measurement_methods"] = Dict[Dict{Any,Any}("eps" => 1.0e-19,"fermiontype" => "Staggered","Nf" => 4,"mass" => 0.5,"measure_every" => 5,"MaxCGstep" => 3000,"methodname" => "Chiral_condensate"), Dict{Any,Any}("fermiontype" => nothing,"measure_every" => 1,"methodname" => "Polyakov_loop"), Dict{Any,Any}("fermiontype" => nothing,"numflow" => 10,"measure_every" => 5,"methodname" => "Topological_charge"), Dict{Any,Any}("eps" => 1.0e-19,"fermiontype" => "Wilson","r" => 1,"measure_every" => 5,"hop" => 0.141139,"methodname" => "Pion_correlator","MaxCGstep" => 3000), Dict{Any,Any}("fermiontype" => nothing,"measure_every" => 1,"methodname" => "Plaquette")]
measurement["measurement_dir"] = "HMC_L04040404_beta5.7_quenched_su3"
measurement["measurement_basedir"] = "./measurements"
# - - - - - - - - - - - - - - - - - - -
