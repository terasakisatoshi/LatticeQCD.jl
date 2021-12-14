module Gaugefields_4D_mpi_module
    using LinearAlgebra
    import ..AbstractGaugefields_module:AbstractGaugefields,Shifted_Gaugefields,shift_U,
                        Adjoint_Gaugefields,set_wing_U!,Abstractfields,construct_staple!,clear_U!,
                        calculate_Plaquet
    import Base
    import ..Gaugefields_4D_module:Gaugefields_4D
    using MPI

    const comm = MPI.COMM_WORLD

    struct Gaugefields_4D_wing_mpi{NC} <: Gaugefields_4D{NC}
        U::Array{ComplexF64,6}
        NX::Int64
        NY::Int64
        NZ::Int64
        NT::Int64
        NDW::Int64
        NV::Int64
        NC::Int64
        PEs::NTuple{4,Int64}
        PN::NTuple{4,Int64}
        mpiinit::Bool
        myrank::Int64
        nprocs::Int64
        myrank_xyzt::NTuple{4,Int64}

        function Gaugefields_4D_wing_mpi(NC::T,NDW::T,NX::T,NY::T,NZ::T,NT::T,PEs;mpiinit=true) where T<: Integer
            NV = NX*NY*NZ*NT
            @assert NX % PEs[1] == 0 "NX % PEs[1] should be 0. Now NX = $NX and PEs = $PEs"
            @assert NY % PEs[2] == 0 "NY % PEs[2] should be 0. Now NY = $NY and PEs = $PEs"
            @assert NZ % PEs[3] == 0 "NZ % PEs[3] should be 0. Now NZ = $NZ and PEs = $PEs"
            @assert NT % PEs[4] == 0 "NT % PEs[4] should be 0. Now NT = $NT and PEs = $PEs"

            PN = (NX ÷ PEs[1],
                    NY ÷ PEs[2],
                    NZ ÷ PEs[3],
                    NT ÷ PEs[4],
            )

            if mpiinit == false
                MPI.Init()
                mpiinit = true
            end

            comm = MPI.COMM_WORLD

            nprocs = MPI.Comm_size(comm)
            @assert prod(PEs) == nprocs "num. of MPI process should be prod(PEs). Now nprocs = $nprocs and PEs = $PEs"
            myrank = MPI.Comm_rank(comm)

            myrank_xyzt = get_myrank_xyzt(myrank,PEs)

            #println("Hello world, I am $(MPI.Comm_rank(comm)) of $(MPI.Comm_size(comm))")

            U = zeros(ComplexF64,NC,NC,PN[1]+2NDW,PN[2]+2NDW,PN[3]+2NDW,PN[4]+2NDW)
            #U = Array{Array{ComplexF64,6}}(undef,4)
            #for μ=1:4
            #    U[μ] = zeros(ComplexF64,NC,NC,NX+2NDW,NY+2NDW,NZ+2NDW,NT+2NDW)
            #end
            return new{NC}(U,NX,NY,NZ,NT,NDW,NV,NC,PEs,PN,mpiinit,myrank,nprocs,myrank_xyzt)
        end
    end

    function get_myrank_xyzt(myrank,PEs)
        #myrank = (((myrank_t)*PEs[3]+myrank_z)*PEs[2] + myrank_y)*PEs[1] + myrank_x
        myrank_x = myrank % PEs[1] 
        i = (myrank - myrank_x) ÷ PEs[1]
        myrank_y = i % PEs[2]
        i = (i - myrank_y) ÷ PEs[2]
        myrank_z = i % PEs[3]
        myrank_t = (i - myrank_z) ÷ PEs[3]

        return myrank_x,myrank_y,myrank_z,myrank_t
    end

    function get_myrank(myrank_xyzt,PEs)
        return (((myrank_xyzt[4])*PEs[3]+myrank_xyzt[3])*PEs[2] + myrank_xyzt[2])*PEs[1] + myrank_xyzt[1]
    end

    function calc_rank_and_indices(x::Gaugefields_4D_wing_mpi,ix,iy,iz,it)
        pex = (ix-1) ÷ x.PN[1]
        ix_local = (ix-1) % x.PN[1] + 1

        pey = (iy-1) ÷ x.PN[2]
        iy_local = (iy-1) % x.PN[2] + 1

        pez = (iz-1) ÷ x.PN[3]
        iz_local = (iz-1) % x.PN[3] + 1

        pet = (it-1) ÷ x.PN[4]
        it_local = (it-1) % x.PN[4] + 1
        myrank = get_myrank((pex,pey,pez,pet),x.PEs)
        return myrank,ix_local,iy_local,iz_local,it_local
    end

    function barrier(x::Gaugefields_4D_wing_mpi)
        MPI.Barrier(comm)
    end

    function Base.setindex!(x::Gaugefields_4D_wing_mpi,v,i1,i2,i3,i4,i5,i6) 
        error("Each element can not be accessed by global index in $(typeof(x)). Use setvalue! function")
        #x.U[i1,i2,i3 + x.NDW,i4 + x.NDW,i5 + x.NDW,i6 + x.NDW] = v
    end

    function Base.getindex(x::Gaugefields_4D_wing_mpi,i1,i2,i3,i4,i5,i6) 
        error("Each element can not be accessed by global index in $(typeof(x)) Use getvalue function")
        #return x.U[i1,i2,i3 .+ x.NDW,i4 .+ x.NDW,i5 .+ x.NDW,i6 .+ x.NDW]
    end

    function getvalue(x::Gaugefields_4D_wing_mpi,i1,i2,i3,i4,i5,i6)
        return x.U[i1,i2,i3 .+ x.NDW,i4 .+ x.NDW,i5 .+ x.NDW,i6 .+ x.NDW]
    end

    function setvalue!(x::Gaugefields_4D_wing_mpi,v,i1,i2,i3,i4,i5,i6)
        x.U[i1,i2,i3 + x.NDW,i4 + x.NDW,i5 + x.NDW,i6 + x.NDW] = v
    end

    function identityGaugefields_4D_wing_mpi(NC,NX,NY,NZ,NT,NDW,PEs;mpiinit = true)
        U = Gaugefields_4D_wing_mpi(NC,NDW,NX,NY,NZ,NT,PEs,mpiinit = mpiinit)
        v = 1

        for it=1:U.PN[4]
            for iz=1:U.PN[3]
                for iy=1:U.PN[2]
                    for ix=1:U.PN[1]
                        @simd for ic=1:NC
                            setvalue!(U,v,ic,ic,ix,iy,iz,it)
                        end
                    end
                end
            end
        end
        set_wing_U!(U)

        return U
    end

    function set_wing_U!(u::Array{Gaugefields_4D_wing_mpi{NC},1}) where NC
        for μ=1:4
            set_wing_U!(u[μ]) 
        end
    end

    function set_wing_U!(u::Gaugefields_4D_wing_mpi{NC}) where NC
        NT = u.NT
        NY = u.NY
        NZ = u.NZ
        NX = u.NX
        NDW = u.NDW
        PEs = u.PEs
        PN = u.PN
        myrank = u.myrank
        myrank_xyzt = u.myrank_xyzt
        myrank_xyzt_send = u.myrank_xyzt
        
    
        #X direction 
        #Now we send data
        #from NX to 1
        N = PN[2]*PN[3]*PN[4]*NDW*NC*NC
        send_mesg1 = Array{ComplexF64}(undef, N)
        recv_mesg1 = Array{ComplexF64}(undef, N)

        count = 0
        for it=1:PN[4]
            for iz=1:PN[3]
                for iy=1:PN[2]
                    for id=1:NDW
                        for k2=1:NC
                            for k1=1:NC
                                count += 1
                                send_mesg1[count] = getvalue(u,k1,k2,PN[1]+(id-NDW),iy,iz,it)
                                #u[k1,k2,-NDW+id,iy,iz,it] = u[k1,k2,NX+(id-NDW),iy,iz,it]
                            end
                        end
                    end
                end
            end
        end

        px = myrank_xyzt[1] + 1
        px += ifelse(px >= PEs[1],-PEs[1],0)        
        myrank_xyzt_send = (px,myrank_xyzt[2],myrank_xyzt[3],myrank_xyzt[4])
        myrank_send1 = get_myrank(myrank_xyzt_send,PEs)
        #println("rank = $rank, myrank_send1 = $(myrank_send1)")
        sreq1 = MPI.Isend(send_mesg1, myrank_send1, myrank_send1+32, comm) #from left to right 0 -> 1

        N = PN[2]*PN[3]*PN[4]*NDW*NC*NC
        send_mesg2 = Array{ComplexF64}(undef, N)
        recv_mesg2 = Array{ComplexF64}(undef, N)

        count = 0
        for it=1:PN[4]
            for iz=1:PN[3]
                for iy=1:PN[2]
                    for id=1:NDW
                        for k2=1:NC
                            for k1=1:NC
                                count += 1
                                send_mesg2[count] = getvalue(u,k1,k2,id,iy,iz,it)
                            end
                        end
                    end
                end
            end
        end
        px = myrank_xyzt[1] - 1
        px += ifelse(px < 0,PEs[1],0)
        #println("px = $px")        
        myrank_xyzt_send = (px,myrank_xyzt[2],myrank_xyzt[3],myrank_xyzt[4])
        myrank_send2 = get_myrank(myrank_xyzt_send,PEs)
        #println("rank = $rank, myrank_send2 = $(myrank_send2)")
        sreq2 = MPI.Isend(send_mesg2, myrank_send2, myrank_send2+64, comm) #from right to left 0 -> -1

        #=
        myrank = 1: myrank_send1 = 2, myrank_send2 = 0
            sreq1: from 1 to 2 2
            sreq2: from 1 to 0 2
        myrank = 2: myrank_send1 = 3, myrank_send2 = 1
            sreq1: from 2 to 3 3
            sreq2: from 2 to 1 1
            rreq1: from 1 to 2 2 -> sreq1 at myrank 1
            rreq2: from 3 to 2 2 
        myrank = 3: myrank_send1 = 4, myrank_send2 = 2
            sreq1: from 3 to 4 4
            sreq2: from 3 to 2 2
        =#

        rreq1 = MPI.Irecv!(recv_mesg1, myrank_send2, myrank+32, comm) #from -1 to 0
        rreq2 = MPI.Irecv!(recv_mesg2, myrank_send1, myrank+64, comm) #from 1 to 0

        stats = MPI.Waitall!([rreq1, sreq1,rreq2,sreq2])
        MPI.Barrier(comm)

        count = 0
        for it=1:PN[4]
            for iz=1:PN[3]
                for iy=1:PN[2]
                    for id=1:NDW
                        for k2=1:NC
                            for k1=1:NC
                                count += 1
                                v = recv_mesg1[count]
                                setvalue!(u,v,k1,k2,-NDW+id,iy,iz,it)
                                #send_mesg1[count] = getvalue(u,k1,k2,PN[1]+(id-NDW),iy,iz,it)
                                #u[k1,k2,-NDW+id,iy,iz,it] = u[k1,k2,NX+(id-NDW),iy,iz,it]
                            end
                        end
                    end
                end
            end
        end

        count = 0
        for it=1:PN[4]
            for iz=1:PN[3]
                for iy=1:PN[2]
                    for id=1:NDW
                        for k2=1:NC
                            for k1=1:NC
                                count += 1
                                v = recv_mesg2[count]
                                setvalue!(u,v,k1,k2,PN[1]+id,iy,iz,it)
                                #u[k1,k2,NX+id,iy,iz,it] = u[k1,k2,id,iy,iz,it]
                                #send_mesg2[count] = getvalue(u,k1,k2,id,iy,iz,it)
                            end
                        end
                    end
                end
            end
        end


        #N = PN[1]*PN[3]*PN[4]*NDW*NC*NC
        N = PN[4]*PN[3]*length(-NDW+1:PN[1]+NDW)*NDW*NC*NC
        send_mesg1 = Array{ComplexF64}(undef, N)
        recv_mesg1 = Array{ComplexF64}(undef, N)
        send_mesg2 = Array{ComplexF64}(undef, N)
        recv_mesg2 = Array{ComplexF64}(undef, N)

        #Y direction 
        #Now we send data
        count = 0
        for it=1:PN[4]
            for iz=1:PN[3]
                for ix=-NDW+1:PN[1]+NDW
                    for id=1:NDW
                        for k1=1:NC
                            for k2=1:NC
                                count += 1
                                send_mesg1[count] = getvalue(u,k1,k2,ix,PN[2]+(id-NDW),iz,it)
                                #u[k1,k2,ix,-NDW+id,iz,it] = u[k1,k2,ix,NY+(id-NDW),iz,it]
                            end
                        end
                    end
                end
            end
        end

        py = myrank_xyzt[2] + 1
        py += ifelse(py >= PEs[2],-PEs[2],0)        
        myrank_xyzt_send = (myrank_xyzt[1],py,myrank_xyzt[3],myrank_xyzt[4])
        myrank_send1 = get_myrank(myrank_xyzt_send,PEs)
        #println("rank = $rank, myrank_send1 = $(myrank_send1)")
        sreq1 = MPI.Isend(send_mesg1, myrank_send1, myrank_send1+32, comm) #from left to right 0 -> 1

    
        count = 0
        for it=1:PN[4]
            for iz=1:PN[3]
                for ix=-NDW+1:PN[1]+NDW
                    for id=1:NDW
                        for k1=1:NC
                            for k2=1:NC
                                count += 1
                                send_mesg2[count] = getvalue(u,k1,k2,ix,id,iz,it)
                                #u[k1,k2,ix,NY+id,iz,it] = u[k1,k2,ix,id,iz,it]
                            end
                        end
                    end
                end
            end
        end

        py = myrank_xyzt[2] - 1
        py += ifelse(py < 0,PEs[2],0)
        #println("py = $py")        
        myrank_xyzt_send = (myrank_xyzt[1],py,myrank_xyzt[3],myrank_xyzt[4])
        myrank_send2 = get_myrank(myrank_xyzt_send,PEs)
        #println("rank = $rank, myrank_send2 = $(myrank_send2)")
        sreq2 = MPI.Isend(send_mesg2, myrank_send2, myrank_send2+64, comm) #from right to left 0 -> -1

        rreq1 = MPI.Irecv!(recv_mesg1, myrank_send2, myrank+32, comm) #from -1 to 0
        rreq2 = MPI.Irecv!(recv_mesg2, myrank_send1, myrank+64, comm) #from 1 to 0

        stats = MPI.Waitall!([rreq1, sreq1,rreq2,sreq2])

        count = 0
        for it=1:PN[4]
            for iz=1:PN[3]
                for ix=-NDW+1:PN[1]+NDW
                    for id=1:NDW
                        for k1=1:NC
                            for k2=1:NC
                                count += 1
                                v = recv_mesg1[count] 
                                setvalue!(u,v,k1,k2,ix,-NDW+id,iz,it)
                                #send_mesg1[count] = getvalue(u,k1,k2,ix,PN[2]+(id-NDW),iz,it)
                                #u[k1,k2,ix,-NDW+id,iz,it] = u[k1,k2,ix,NY+(id-NDW),iz,it]
                            end
                        end
                    end
                end
            end
        end

        count = 0
        for it=1:PN[4]
            for iz=1:PN[3]
                for ix=-NDW+1:PN[1]+NDW
                    for id=1:NDW
                        for k1=1:NC
                            for k2=1:NC
                                count += 1
                                v = recv_mesg2[count]
                                setvalue!(u,v,k1,k2,ix,NY+id,iz,it)
                                #send_mesg2[count] = getvalue(u,k1,k2,ix,id,iz,it)
                                #u[k1,k2,ix,NY+id,iz,it] = u[k1,k2,ix,id,iz,it]
                            end
                        end
                    end
                end
            end
        end


        MPI.Barrier(comm)

        #Z direction 
        #Now we send data

        N = NDW*PN[4]*length(-NDW+1:PN[2]+NDW)*length(-NDW+1:PN[1]+NDW)*NC*NC
        send_mesg1 = Array{ComplexF64}(undef, N)
        recv_mesg1 = Array{ComplexF64}(undef, N)
        send_mesg2 = Array{ComplexF64}(undef, N)
        recv_mesg2 = Array{ComplexF64}(undef, N)

        count = 0
        for id=1:NDW
            for it=1:PN[4]
                for iy=-NDW+1:PN[2]+NDW
                    for ix=-NDW+1:PN[1]+NDW
                        for k1=1:NC
                            for k2=1:NC
                                count += 1
                                send_mesg1[count] = getvalue(u,k1,k2,ix,iy,PN[3]+(id-NDW),it)
                                send_mesg2[count] = getvalue(u,k1,k2,ix,iy,id,it)
                                #u[k1,k2,ix,iy,id-NDW,it] = u[k1,k2,ix,iy,NZ+(id-NDW),it]
                                #u[k1,k2,ix,iy,NZ+id,it] = u[k1,k2,ix,iy,id,it]
                            end
                        end
                    end
                end
            end
        end

        pz = myrank_xyzt[3] + 1
        pz += ifelse(pz >= PEs[3],-PEs[3],0)        
        myrank_xyzt_send = (myrank_xyzt[1],myrank_xyzt[2],pz,myrank_xyzt[4])
        myrank_send1 = get_myrank(myrank_xyzt_send,PEs)
        #println("rank = $rank, myrank_send1 = $(myrank_send1)")
        sreq1 = MPI.Isend(send_mesg1, myrank_send1, myrank_send1+32, comm) #from left to right 0 -> 1

        pz = myrank_xyzt[3] - 1
        pz += ifelse(pz < 0,PEs[3],0)
        #println("pz = $pz")        
        myrank_xyzt_send = (myrank_xyzt[1],myrank_xyzt[2],pz,myrank_xyzt[4])
        myrank_send2 = get_myrank(myrank_xyzt_send,PEs)
        #println("rank = $rank, myrank_send2 = $(myrank_send2)")
        sreq2 = MPI.Isend(send_mesg2, myrank_send2, myrank_send2+64, comm) #from right to left 0 -> -1

        rreq1 = MPI.Irecv!(recv_mesg1, myrank_send2, myrank+32, comm) #from -1 to 0
        rreq2 = MPI.Irecv!(recv_mesg2, myrank_send1, myrank+64, comm) #from 1 to 0

        stats = MPI.Waitall!([rreq1, sreq1,rreq2,sreq2])

        count = 0
        for id=1:NDW
            for it=1:PN[4]
                for iy=-NDW+1:PN[2]+NDW
                    for ix=-NDW+1:PN[1]+NDW
                        for k1=1:NC
                            for k2=1:NC
                                count += 1
                                v = recv_mesg1[count]
                                setvalue!(u,v,k1,k2,ix,iy,id-NDW,it)
                                v = recv_mesg2[count]
                                setvalue!(u,v,k1,k2,ix,iy,PN[3]+id,it)
                                #u[k1,k2,ix,iy,id-NDW,it] = u[k1,k2,ix,iy,NZ+(id-NDW),it]
                                #u[k1,k2,ix,iy,NZ+id,it] = u[k1,k2,ix,iy,id,it]
                            end
                        end
                    end
                end
            end
        end

        MPI.Barrier(comm)
        
        #T direction 
        #Now we send data

        N = NDW*length(-NDW+1:PN[3]+NDW)*length(-NDW+1:PN[2]+NDW)*length(-NDW+1:PN[1]+NDW)*NC*NC
        send_mesg1 = Array{ComplexF64}(undef, N)
        recv_mesg1 = Array{ComplexF64}(undef, N)
        send_mesg2 = Array{ComplexF64}(undef, N)
        recv_mesg2 = Array{ComplexF64}(undef, N)
    
        count = 0
        for id=1:NDW
            for iz=-NDW+1:PN[3]+NDW
                for iy=-NDW+1:PN[2]+NDW
                    for ix=-NDW+1:PN[1]+NDW
                        for k1=1:NC
                            for k2=1:NC
                                count += 1
                                send_mesg1[count] = getvalue(u,k1,k2,ix,iy,iz,PN[4]+(id-NDW))
                                send_mesg2[count] = getvalue(u,k1,k2,ix,iy,iz,id)
                                #u[k1,k2,ix,iy,iz,id-NDW] = u[k1,k2,ix,iy,iz,PN[4]+(id-NDW)]
                                #u[k1,k2,ix,iy,iz,PN[4]+id] = u[k1,k2,ix,iy,iz,id]
                            end
                        end
                    end
                end
            end
        end

        pt = myrank_xyzt[4] + 1
        pt += ifelse(pt >= PEs[4],-PEs[4],0)        
        myrank_xyzt_send = (myrank_xyzt[1],myrank_xyzt[2],myrank_xyzt[3],pt)
        myrank_send1 = get_myrank(myrank_xyzt_send,PEs)
        #println("rank = $rank, myrank_send1 = $(myrank_send1)")
        sreq1 = MPI.Isend(send_mesg1, myrank_send1, myrank_send1+32, comm) #from left to right 0 -> 1

        pt = myrank_xyzt[4] - 1
        pt += ifelse(pt < 0,PEs[4],0)
        #println("pt = $pt")        
        myrank_xyzt_send = (myrank_xyzt[1],myrank_xyzt[2],myrank_xyzt[3],pt)
        myrank_send2 = get_myrank(myrank_xyzt_send,PEs)
        #println("rank = $rank, myrank_send2 = $(myrank_send2)")
        sreq2 = MPI.Isend(send_mesg2, myrank_send2, myrank_send2+64, comm) #from right to left 0 -> -1

        rreq1 = MPI.Irecv!(recv_mesg1, myrank_send2, myrank+32, comm) #from -1 to 0
        rreq2 = MPI.Irecv!(recv_mesg2, myrank_send1, myrank+64, comm) #from 1 to 0

        stats = MPI.Waitall!([rreq1, sreq1,rreq2,sreq2])

        count = 0
        for id=1:NDW
            for iz=-NDW+1:PN[3]+NDW
                for iy=-NDW+1:PN[2]+NDW
                    for ix=-NDW+1:PN[1]+NDW
                        for k1=1:NC
                            for k2=1:NC
                                count += 1
                                v = recv_mesg1[count]
                                setvalue!(u,v,k1,k2,ix,iy,iz,id-NDW)
                                v = recv_mesg2[count]
                                setvalue!(u,v,k1,k2,ix,iy,iz,PN[4]+id)

                                #send_mesg1[count] = getvalue(u,k1,k2,ix,iy,iz,PN[4]+(id-NDW))
                                #send_mesg2[count] = getvalue(u,k1,k2,ix,iy,iz,id)
                                #u[k1,k2,ix,iy,iz,id-NDW] = u[k1,k2,ix,iy,iz,PN[4]+(id-NDW)]
                                #u[k1,k2,ix,iy,iz,PN[4]+id] = u[k1,k2,ix,iy,iz,id]
                            end
                        end
                    end
                end
            end
        end
        #error("rr22r")


        MPI.Barrier(comm)
    
        return
    end


    

end