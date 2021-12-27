module AbstractGaugefields_module
    using LinearAlgebra
    import ..Actions:GaugeActionParam,GaugeActionParam_standard,GaugeActionParam_autogenerator,
                        SmearingParam_single,SmearingParam_multi,SmearingParam,Nosmearing
    import ..Wilsonloops:Wilson_loop_set,calc_coordinate,make_plaq_staple_prime,calc_shift,make_plaq,make_plaq_staple,
                        Tensor_wilson_lines_set,Tensor_wilson_lines,Tensor_derivative_set,
                        get_leftstartposition,get_rightstartposition,Wilson_loop   
    import ..Actions:GaugeActionParam_autogenerator,SmearingParam_single,SmearingParam_multi,SmearingParam
    using MPI

    

    #using InteractiveUtils
    abstract type SUn end

    abstract type SU{N} <: SUn
    end

    const U1 = SU{1}
    const SU2 = SU{2}
    const SU3 = SU{3}

    abstract type Abstractfields end

    abstract type AbstractGaugefields{NC,Dim} <: Abstractfields
    end

    abstract type Adjoint_fields{T} <: Abstractfields
    end

    struct Adjoint_Gaugefields{T} <: Adjoint_fields{T}
        parent::T
    end

    function Base.adjoint(U::T) where T <: Abstractfields
        Adjoint_Gaugefields{T}(U)
    end

    struct Shifted_Gaugefields{T,Dim} <: Abstractfields
        parent::T
        shift::NTuple{Dim,Int8}

        function Shifted_Gaugefields(U::T,shift,Dim) where {T <: AbstractGaugefields}
            return new{T,Dim}(U,shift)
        end
    end

    include("./gaugefields_4D.jl")
    include("./gaugefields_4D_wing.jl")
    include("./gaugefields_4D_mpi.jl")
    #include("./gaugefields_4D_wing_mpi.jl")


    function Base.similar(U::T) where T <: AbstractGaugefields
        error("similar! is not implemented in type $(typeof(U)) ")
    end

    function substitute_U!(a::Array{T,1},b::Array{T,1}) where T <: AbstractGaugefields
        error("substitute_U! is not implemented in type $(typeof(a)) ")
    end

    function substitute_U!(a::T,b::T) where T <: AbstractGaugefields
        error("substitute_U! is not implemented in type $(typeof(a)) ")
        return 
    end

    function construct_gauges(NC,NDW,NN...;mpi = false,PEs=nothing,mpiinit = nothing)
        dim = length(NN)
        if mpi
            if PEs == nothing || mpiinit == nothing
                error("not implemented yet!")
            else
                if dim==4
                    U = identityGaugefields_4D_wing_mpi(NC,NN[1],NN[2],NN[3],NN[4],NDW,PEs,mpiinit = mpiinit)
                else
                    error("not implemented yet!")
                end
                
            end
        else
            if dim == 4
                U = identityGaugefields_4D_wing(NC,NN[1],NN[2],NN[3],NN[4],NDW)
            else
                error("not implemented yet!")
            end
        end
        return U
    end



    function clear_U!(U::T) where T <: AbstractGaugefields
        error("clear_U! is not implemented in type $(typeof(U)) ")
    end

    function shift_U(U::T,ν) where T <: AbstractGaugefields
        error("shift_U is not implemented in type $(typeof(U)) ")
    end

    function identitymatrix(U::T) where T <: AbstractGaugefields
        error("identitymatrix is not implemented in type $(typeof(U)) ")
    end

    function set_wing_U!(U::T) where T <: AbstractGaugefields
        error("set_wing_U! is not implemented in type $(typeof(U)) ")
    end

    function evaluate_wilson_loops!(xout::T,w::Wilson_loop_set,U::Array{T,1},temps::Array{T,1}) where T<: AbstractGaugefields

        num = length(w)
        clear_U!(xout)
        Uold = temps[1]
        Unew = temps[2]


        for i=1:num
            wi = w[i]
            numloops = length(wi)    
    
            shifts = calc_shift(wi)
            #println("shift ",shifts)
            
            loopk = wi[1]
            k = 1
            #println("k = $k shift: ",shifts[k])
            substitute_U!(Uold,U[loopk[1]])
            Ushift1 = shift_U(Uold,shifts[1])

            #gauge_shift_all!(temp1,shifts[1],U[loopk[1]])

            
            loopk1_2 = loopk[2]
            for k=2:numloops
                loopk = wi[k]
                #println("k = $k shift: ",shifts[k])
                #println("gauge_shift!(temp2,$(shifts[k]),$(loopk[1]) )")
                #clear!(temp2)
                Ushift2 = shift_U(U[loopk[1]],shifts[k])
                #gauge_shift_all!(temp2,shifts[k],U[loopk[1]])

                #multiply_12!(temp3,temp1,temp2,k,loopk,loopk1_2)
                multiply_12!(Unew,Ushift1,Ushift2,k,loopk,loopk1_2)
                Unew,Uold = Uold,Unew
                Ushift1 = Uold
                #temp1,temp3 = temp3,temp1

                
            end
            add_U!(xout,Ushift1)
            #add!(xout,temp1)
            
        end
    end


    function multiply_12!(temp3,temp1,temp2,k,loopk,loopk1_2)
        if loopk[2] == 1
            if k==2
                if loopk1_2 == 1
                    mul!(temp3,temp1,temp2)
                else
                    mul!(temp3,temp1',temp2)
                end
            else
                mul!(temp3,temp1,temp2)
            end
        elseif loopk[2] == -1
            if k==2
                if loopk1_2 == 1
                    mul!(temp3,temp1,temp2')
                else
                    mul!(temp3,temp1',temp2')
                end
            else
                mul!(temp3,temp1,temp2')
            end
        else
            error("Second element should be 1 or -1 but now $(loopk)")
        end
        return
    end


    function calculate_Plaquette(U::Array{T,1}) where T <: AbstractGaugefields
        error("calculate_Plaquette is not implemented in type $(typeof(U)) ")
    end

    function calculate_Plaquette(U::Array{T,1},temp::AbstractGaugefields{NC,Dim},staple::AbstractGaugefields{NC,Dim}) where {NC,Dim,T <: AbstractGaugefields}
        plaq = 0
        V = staple
        for μ=1:Dim
            construct_staple!(V,U,μ,temp)
            mul!(temp,U[μ],V')
            plaq += tr(temp)
            
        end

        if Dim == 4
            comb = 6 #4*3/2
        elseif Dim == 3
            comb = 3
        elseif Dim == 2
            comb = 1
        else
            error("dimension $Dim is not supported")
        end
        factor = 1/(comb*U[1].NV*U[1].NC)

        return real(plaq*0.5*factor)
    end

    function construct_staple!(staple::AbstractGaugefields,U,μ) where T <: AbstractGaugefields
        error("construct_staple! is not implemented in type $(typeof(U)) ")
    end

    
    function add_force!(F::Array{T,1},U::Array{T,1},temps::Array{<: AbstractGaugefields{NC,Dim},1},gparam::GP;factor = 1) where {NC,Dim,T <: AbstractGaugefields,GP <: GaugeActionParam_autogenerator}
        @assert length(temps) >= 3 "length(temps) should be >= 3. But $(length(temps))"
        clear_U!(F)
        V = temps[3]  
        temp1 = temps[1]
        temp2 = temps[2]    

        for μ=1:Dim
            clear_U!(V)
            for i=1:gparam.numactions
                loops = gparam.staples[i][μ]
                evaluate_wilson_loops!(temp3,loops,U,[temp1,temp2])
                add_U!(V,gparam.βs[i]/gparam.β,temp3)
            end

            mul!(temp1,U[μ],V) #U U*V
            Traceless_antihermitian!(temp2,temp1)
            add_U!(F[μ],factor,temp2)
        end

        set_wing_U!(F)

    end

    function add_force!(F::Array{T,1},U::Array{T,1},temps::Array{<: AbstractGaugefields{NC,Dim},1},gparam::GP;factor = 1) where {NC,Dim,T <: AbstractGaugefields,GP}
        @assert length(temps) >= 3 "length(temps) should be >= 3. But $(length(temps))"
        clear_U!(F)
        V = temps[3]  
        temp1 = temps[1]
        temp2 = temps[2]    

        for μ=1:Dim
            construct_double_staple!(V,U,μ,temps[1:2])

            mul!(temp1,U[μ],V') #U U*V

            a = temp1[:,:,1,1,1,1]
            println(a'*a)

            Traceless_antihermitian!(temp2,temp1)
            #println(temp2[1,1,1,1,1,1])
            a = temp2[:,:,1,1,1,1]
            println(a'*a)
            error("a")
            add_U!(F[μ],factor,temp2)
        end
    end

    function exptU!(uout::T,t::N,u::T,temps::Array{T,1}) where {N <: Number, T <: AbstractGaugefields} #uout = exp(t*u)
        error("expUt! is not implemented in type $(typeof(u)) ")
    end


    function exptU!(uout::T,u::T,temps::Array{T,1}) where T <: AbstractGaugefields
        expU!(uout,1,u,temps)
    end

    function exp_aF_U!(W::Array{<: AbstractGaugefields{NC,Dim},1},a::N,F::Array{T,1},U::Array{T,1},temps::Array{T,1}) where {NC,Dim,N <: Number, T <: AbstractGaugefields} #exp(a*F)*U
        @assert a != 0 "Δτ should not be zero in expF_U! function!"
        expU = temps[1]
        temp1 = temps[2]
        temp2 = temps[3]

        for μ=1:Dim
            exptU!(expU,a,F[μ],[temp1,temp2])
            mul!(W[μ],expU,U[μ])
        end

        set_wing_U!(W)

        #error("exp_aF_U! is not implemented in type $(typeof(U)) ")
    end

    
    
    function staple_prime()
        loops_staple_prime = Array{Wilson_loop_set,2}(undef,4,4)
        for Dim=1:4
            for μ=1:Dim
                loops_staple_prime[Dim,μ] = make_plaq_staple_prime(μ,Dim)
            end
        end
        return loops_staple_prime
    end
    const loops_staple_prime = staple_prime()


    function construct_double_staple!(staple::AbstractGaugefields{NC,Dim},U::Array{T,1},μ,temps::Array{<: AbstractGaugefields{NC,Dim},1}) where {NC,Dim,T <: AbstractGaugefields}
        loops = loops_staple_prime[Dim,μ] #make_plaq_staple_prime(μ,Dim)
        evaluate_wilson_loops!(staple,loops,U,temps)
    end


    function construct_staple!(staple::AbstractGaugefields{NC,Dim},U::Array{T,1},μ,temp::AbstractGaugefields{NC,Dim}) where {NC,Dim,T <: AbstractGaugefields}
        U1U2 = temp
        firstterm = true

        for ν=1:Dim
            if ν == μ
                continue
            end
            
            #=
                    x+nu temp2
                    .---------.
                    I         I
              temp1 I         I
                    I         I
                    .         .
                    x        x+mu
            =#
            U1 = U[ν]    
            U2 = shift_U(U[μ],ν)
            #println(typeof(U1))
            mul!(U1U2,U1,U2)
            #error("test")
            
            U3 = shift_U(U[ν],μ)
            #mul!(staple,temp,Uμ')
            #  mul!(C, A, B, α, β) -> C, A B α + C β
            if firstterm
                β = 0
                firstterm = false
            else
                β = 1
            end
            mul!(staple,U1U2,U3',1,β) #C = alpha*A*B + beta*C

            #println("staple ",staple[1,1,1,1,1,1])
            

            #mul!(staple,U0,Uν,Uμ')
        end
        set_wing_U!(staple)
    end

    function Base.size(U::T) where T <: AbstractGaugefields
        error("Base.size is not implemented in type $(typeof(U)) ")
    end

    function calculate_Polyakov_loop(U::Array{T,1},temp1::AbstractGaugefields{NC,Dim},temp2::AbstractGaugefields{NC,Dim}) where {NC,Dim,T <: AbstractGaugefields}
        Uold = temp1
        Unew = temp2
        shift = zeros(Int64,Dim)
        
        μ = Dim
        _,_,NN... = size(U[1]) #NC,NC,NX,NY,NZ,NT 4D case
        lastaxis = NN[end]
        #println(lastaxis)

        substitute_U!(Uold,U[μ])
        for i=2:lastaxis
            shift[μ] = i-1
            U1 = shift_U(U[μ],Tuple(shift))
            mul_skiplastindex!(Unew,Uold,U1)
            Uold,Unew = Unew,Uold
        end

        set_wing_U!(Uold)
        poly = partial_tr(Uold,μ)/prod(NN[1:Dim-1])
        return poly

    end


 
 

    function mul_skiplastindex!(c::T,a::T1,b::T2) where {T <: AbstractGaugefields, T1 <: Abstractfields,T2 <: Abstractfields}
        error("mul_skiplastindex! is not implemented in type $(typeof(c)) ")
    end


    function Traceless_antihermitian(vin::T) where T <: AbstractGaugefields
        vout = deepcopy(vin)
        Traceless_antihermitian!(vout,vin)
        return vout
    end

    function Traceless_antihermitian!(vout::T,vin::T) where T <: AbstractGaugefields
        error("Traceless_antihermitian! is not implemented in type $(typeof(vout)) ")
    end

    function add_U!(c::T,a::T1) where {T<: AbstractGaugefields,T1 <: Abstractfields}
        error("add_U! is not implemented in type $(typeof(c)) ")
    end

    function add_U!(c::Array{<: AbstractGaugefields{NC,Dim},1},α::N,a::Array{T1,1}) where {NC,Dim,T1 <: Abstractfields, N<:Number}
        for μ=1:Dim
            add_U!(c[μ],α,a[μ])
        end
    end

    function add_U!(c::T,α::N,a::T1) where {T<: AbstractGaugefields,T1 <: Abstractfields, N<:Number}
        error("add_U! is not implemented in type $(typeof(c)) ")
    end

    function LinearAlgebra.mul!(c::T,a::T1,b::T2,α::Ta,β::Tb) where {T<: AbstractGaugefields,T1 <: Abstractfields,T2 <: Abstractfields,Ta <: Number, Tb <: Number}
        error("LinearAlgebra.mul! is not implemented in type $(typeof(c)) ")
    end

    function LinearAlgebra.mul!(c::T,a::N,b::T2) where {T<: AbstractGaugefields,N <: Number ,T2 <: Abstractfields}
        error("LinearAlgebra.mul! is not implemented in type $(typeof(c)) ")
    end

    function partial_tr(a::T,μ) where T<: Abstractfields
        error("partial_tr is not implemented in type $(typeof(a)) ")
    end

    function LinearAlgebra.tr(a::T) where T<: Abstractfields
        error("LinearAlgebra.tr! is not implemented in type $(typeof(a)) ")
    end

    """
        Tr(A*B)
    """
    function LinearAlgebra.tr(a::T,b::T) where T<: Abstractfields
        error("LinearAlgebra.tr! is not implemented in type $(typeof(a)) ")
    end

    function calc_smearedU(Uin::Array{T,1},smearing;calcdSdU = false,temps = nothing) where T<: AbstractGaugefields
        if smearing != nothing && typeof(smearing) != Nosmearing
            if typeof(smearing) <: SmearingParam_single
                Uout_multi = nothing
                U = apply_smearing_U(Uin,smearing)
            elseif typeof(smearing) <: SmearingParam_multi
                Uout_multi = apply_smearing_U(Uin,smearing)
                U = Uout_multi[end]
            else
                error("something is wrong in calc_smearingU")
            end
            set_wing!(U)  #we want to remove this.
            if calcdSdU 
                dSdU = [temps[end-3],temps[end-2],temps[end-1],temps[end]]    
            else
                dSdU = nothing
            end
        else
            dSdU = nothing
            Uout_multi = nothing
            U = Uin
        end
        return U,Uout_multi,dSdU
    end

    function apply_smearing_U(Uin::Array{T,1},smearing) where T<: Abstractfields
        error("apply_smearing_U is not implemented in type $(typeof(Uin)) ")
    end


end