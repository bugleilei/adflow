   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
   !  
   !  Differentiation of inviscidcentralfluxadjts in reverse (adjoint) mode:
   !   gradient, with respect to input variables: rotrateadj voladj
   !                padj dwadj wadj sfacekadj skadj sfacejadj sjadj
   !                sfaceiadj siadj
   !   of linear combination of output variables: voladj padj dwadj
   !                wadj
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          inviscidCentralFluxAdj.f90                      *
   !      * Author:        Edwin van der Weide, C.A.(Sandy) Mader          *
   !      *                Seongim Choi                                    *
   !      * Starting date: 11-21-2007                                      *
   !      * Last modified: 10-22-2008                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE INVISCIDCENTRALFLUXADJTS_B(wadj, wadjb, padj, padjb, dwadj, &
   &  dwadjb, siadj, siadjb, sjadj, sjadjb, skadj, skadjb, voladj, voladjb&
   &  , sfaceiadj, sfaceiadjb, sfacejadj, sfacejadjb, sfacekadj, sfacekadjb&
   &  , rotrateadj, rotrateadjb, icell, jcell, kcell, nn, level, sps)
   USE blockpointers
   USE cgnsgrid
   USE flowvarrefstate
   USE inputphysics
   USE inputtimespectral
   IMPLICIT NONE
   REAL(KIND=REALTYPE) :: dwadj(nw, ntimeintervalsspectral), dwadjb(nw, &
   &  ntimeintervalsspectral)
   INTEGER(KIND=INTTYPE) :: icell, jcell, kcell, level, nn, sps
   REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral), INTENT(IN) :: padj
   REAL(KIND=REALTYPE) :: padjb(-2:2, -2:2, -2:2, ntimeintervalsspectral)
   REAL(KIND=REALTYPE), DIMENSION(3), INTENT(IN) :: rotrateadj
   REAL(KIND=REALTYPE) :: rotrateadjb(3)
   REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral), INTENT(IN) :: sfaceiadj
   REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral), INTENT(IN) :: sfacejadj
   REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral), INTENT(IN) :: sfacekadj
   REAL(KIND=REALTYPE) :: sfaceiadjb(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral), sfacejadjb(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral), sfacekadjb(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral)
   REAL(KIND=REALTYPE), DIMENSION(-3:2, -3:2, -3:2, 3, &
   &  ntimeintervalsspectral), INTENT(IN) :: siadj
   REAL(KIND=REALTYPE) :: siadjb(-3:2, -3:2, -3:2, 3, &
   &  ntimeintervalsspectral), sjadjb(-3:2, -3:2, -3:2, 3, &
   &  ntimeintervalsspectral), skadjb(-3:2, -3:2, -3:2, 3, &
   &  ntimeintervalsspectral)
   REAL(KIND=REALTYPE), DIMENSION(-3:2, -3:2, -3:2, 3, &
   &  ntimeintervalsspectral), INTENT(IN) :: sjadj
   REAL(KIND=REALTYPE), DIMENSION(-3:2, -3:2, -3:2, 3, &
   &  ntimeintervalsspectral), INTENT(IN) :: skadj
   REAL(KIND=REALTYPE), DIMENSION(0:0, 0:0, 0:0, ntimeintervalsspectral)&
   &  , INTENT(IN) :: voladj
   REAL(KIND=REALTYPE) :: voladjb(0:0, 0:0, 0:0, ntimeintervalsspectral)
   REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, -2:2, nw, &
   &  ntimeintervalsspectral), INTENT(IN) :: wadj
   REAL(KIND=REALTYPE) :: wadjb(-2:2, -2:2, -2:2, nw, &
   &  ntimeintervalsspectral)
   INTEGER :: branch
   REAL(KIND=REALTYPE) :: fact, fs, fsb, pa, pab, sface, sfaceb, tempb, &
   &  tempb0, tempb1, vnm, vnmb, vnp, vnpb
   INTEGER(KIND=INTTYPE) :: i, ii, j, jj, k, kk
   REAL(KIND=REALTYPE) :: porflux, porvel, qsm, qsmb, qsp, qspb, rqsm, &
   &  rqsmb, rqsp, rqspb
   REAL(KIND=REALTYPE) :: tempb2, tempb3, tempb4
   REAL(KIND=REALTYPE) :: rvol, rvolb, wx, wxb, wy, wyb, wz, wzb
   REAL(KIND=REALTYPE) :: rvol2, wx2, wy2, wz2
   !
   !      ******************************************************************
   !      *                                                                *
   !      * inviscidCentralFluxAdj computes the Euler fluxes using a       *
   !      * central discretization for the cell iCell, jCell, kCell of the *
   !      * block to which the variables in blockPointers currently point  *
   !      * to.                                                            *
   !      *                                                                *
   !      ******************************************************************
   !
   ! sFaceI,sFaceJ,sFaceK,sI,sJ,sK,blockismoving,addgridvelocities
   ! vol, nbkGlobal
   ! constants (irho, ivx, ivy, imx,..), timeRef
   ! equationMode, steady
   !
   !nTimeIntervalsSpectral
   !
   !      Subroutine arguments
   !
   !
   !      Local variables.
   !
   !     testing vars
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Initialize sFace to zero. This value will be used if the
   ! block is not moving.
   sface = 0.0
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Advective fluxes in the i-direction.                           *
   !      *                                                                *
   !      ******************************************************************
   !
   i = icell - 1
   j = jcell
   k = kcell
   fact = -one
   ! Loop over the two faces which contribute to the residual of
   ! the cell considered.
   DO ii=-1,0
   ! Set the dot product of the grid velocity and the
   ! normal in i-direction for a moving face.
   IF (addgridvelocities) THEN
   sface = sfaceiadj(ii, 0, 0, sps)
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   CALL PUSHREAL8(vnp)
   ! Compute the normal velocities of the left and right state.
   vnp = wadj(ii+1, 0, 0, ivx, sps)*siadj(ii, 0, 0, 1, sps) + wadj(ii+1&
   &      , 0, 0, ivy, sps)*siadj(ii, 0, 0, 2, sps) + wadj(ii+1, 0, 0, ivz&
   &      , sps)*siadj(ii, 0, 0, 3, sps)
   CALL PUSHREAL8(vnm)
   vnm = wadj(ii, 0, 0, ivx, sps)*siadj(ii, 0, 0, 1, sps) + wadj(ii, 0&
   &      , 0, ivy, sps)*siadj(ii, 0, 0, 2, sps) + wadj(ii, 0, 0, ivz, sps)&
   &      *siadj(ii, 0, 0, 3, sps)
   CALL PUSHREAL8(porvel)
   !print *,'vnp',wAdj(ii+1,0,0,ivx,sps),sIAdj(ii,0,0,1,sps),sps
   ! Set the values of the porosities for this face.
   ! porVel defines the porosity w.r.t. velocity;
   ! porFlux defines the porosity w.r.t. the entire flux.
   ! The latter is only zero for a discontinuous block
   ! boundary that must be treated conservatively.
   ! The default value of porFlux is 0.5, such that the
   ! correct central flux is scattered to both cells.
   ! In case of a boundFlux the normal velocity is set
   ! to sFace.
   porvel = one
   CALL PUSHREAL8(porflux)
   porflux = half
   IF (pori(i, j, k) .EQ. noflux) THEN
   porflux = 0.0
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   IF (pori(i, j, k) .EQ. boundflux) THEN
   porvel = 0.0
   vnp = sface
   vnm = sface
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   ! Incorporate porFlux in porVel.
   porvel = porvel*porflux
   CALL PUSHREAL8(qsp)
   ! Compute the normal velocities relative to the grid for
   ! the face as well as the mass fluxes.
   qsp = (vnp-sface)*porvel
   CALL PUSHREAL8(qsm)
   qsm = (vnm-sface)*porvel
   CALL PUSHREAL8(rqsp)
   rqsp = qsp*wadj(ii+1, 0, 0, irho, sps)
   CALL PUSHREAL8(rqsm)
   rqsm = qsm*wadj(ii, 0, 0, irho, sps)
   CALL PUSHREAL8(pa)
   ! Compute the sum of the pressure multiplied by porFlux.
   ! For the default value of porFlux, 0.5, this leads to
   ! the average pressure.
   pa = porflux*(padj(ii+1, 0, 0, sps)+padj(ii, 0, 0, sps))
   ! Compute the fluxes through this face.
   ! Update i and set fact to 1 for the second face.
   i = i + 1
   CALL PUSHREAL8(fact)
   fact = one
   END DO
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Advective fluxes in the j-direction.                           *
   !      *                                                                *
   !      ******************************************************************
   !
   i = icell
   j = jcell - 1
   k = kcell
   fact = -one
   ! Loop over the two faces which contribute to the residual of
   ! the cell considered.
   DO jj=-1,0
   ! Set the dot product of the grid velocity and the
   ! normal in j-direction for a moving face.
   IF (addgridvelocities) THEN
   sface = sfacejadj(0, jj, 0, sps)
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   CALL PUSHREAL8(vnp)
   ! Compute the normal velocities of the left and right state.
   vnp = wadj(0, jj+1, 0, ivx, sps)*sjadj(0, jj, 0, 1, sps) + wadj(0, &
   &      jj+1, 0, ivy, sps)*sjadj(0, jj, 0, 2, sps) + wadj(0, jj+1, 0, ivz&
   &      , sps)*sjadj(0, jj, 0, 3, sps)
   CALL PUSHREAL8(vnm)
   vnm = wadj(0, jj, 0, ivx, sps)*sjadj(0, jj, 0, 1, sps) + wadj(0, jj&
   &      , 0, ivy, sps)*sjadj(0, jj, 0, 2, sps) + wadj(0, jj, 0, ivz, sps)&
   &      *sjadj(0, jj, 0, 3, sps)
   CALL PUSHREAL8(porvel)
   ! Set the values of the porosities for this face.
   ! porVel defines the porosity w.r.t. velocity;
   ! porFlux defines the porosity w.r.t. the entire flux.
   ! The latter is only zero for a discontinuous block
   ! boundary that must be treated conservatively.
   ! The default value of porFlux is 0.5, such that the
   ! correct central flux is scattered to both cells.
   ! In case of a boundFlux the normal velocity is set
   ! to sFace.
   porvel = one
   CALL PUSHREAL8(porflux)
   porflux = half
   IF (porj(i, j, k) .EQ. noflux) THEN
   porflux = 0.0
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   IF (porj(i, j, k) .EQ. boundflux) THEN
   porvel = 0.0
   vnp = sface
   vnm = sface
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   ! Incorporate porFlux in porVel.
   porvel = porvel*porflux
   CALL PUSHREAL8(qsp)
   ! Compute the normal velocities relative to the grid for
   ! the face as well as the mass fluxes.
   qsp = (vnp-sface)*porvel
   CALL PUSHREAL8(qsm)
   qsm = (vnm-sface)*porvel
   CALL PUSHREAL8(rqsp)
   rqsp = qsp*wadj(0, jj+1, 0, irho, sps)
   CALL PUSHREAL8(rqsm)
   rqsm = qsm*wadj(0, jj, 0, irho, sps)
   CALL PUSHREAL8(pa)
   ! Compute the sum of the pressure multiplied by porFlux.
   ! For the default value of porFlux, 0.5, this leads to
   ! the average pressure.
   pa = porflux*(padj(0, jj+1, 0, sps)+padj(0, jj, 0, sps))
   ! Compute the fluxes through this face.
   ! Update j and set fact to 1 for the second face.
   j = j + 1
   CALL PUSHREAL8(fact)
   fact = one
   END DO
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Advective fluxes in the k-direction.                           *
   !      *                                                                *
   !      ******************************************************************
   !
   !       should this be inside, have k=kCell+kk?
   i = icell
   j = jcell
   k = kcell - 1
   fact = -one
   ! Loop over the two faces which contribute to the residual of
   ! the cell considered.
   DO kk=-1,0
   ! Set the dot product of the grid velocity and the
   ! normal in k-direction for a moving face.
   IF (addgridvelocities) THEN
   sface = sfacekadj(0, 0, kk, sps)
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   CALL PUSHREAL8(vnp)
   ! Compute the normal velocities of the left and right state.
   vnp = wadj(0, 0, kk+1, ivx, sps)*skadj(0, 0, kk, 1, sps) + wadj(0, 0&
   &      , kk+1, ivy, sps)*skadj(0, 0, kk, 2, sps) + wadj(0, 0, kk+1, ivz&
   &      , sps)*skadj(0, 0, kk, 3, sps)
   CALL PUSHREAL8(vnm)
   vnm = wadj(0, 0, kk, ivx, sps)*skadj(0, 0, kk, 1, sps) + wadj(0, 0, &
   &      kk, ivy, sps)*skadj(0, 0, kk, 2, sps) + wadj(0, 0, kk, ivz, sps)*&
   &      skadj(0, 0, kk, 3, sps)
   CALL PUSHREAL8(porvel)
   ! Set the values of the porosities for this face.
   ! porVel defines the porosity w.r.t. velocity;
   ! porFlux defines the porosity w.r.t. the entire flux.
   ! The latter is only zero for a discontinuous block
   ! boundary that must be treated conservatively.
   ! The default value of porFlux is 0.5, such that the
   ! correct central flux is scattered to both cells.
   ! In case of a boundFlux the normal velocity is set
   ! to sFace.
   porvel = one
   CALL PUSHREAL8(porflux)
   porflux = half
   IF (pork(i, j, k) .EQ. noflux) THEN
   porflux = 0.0
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   IF (pork(i, j, k) .EQ. boundflux) THEN
   porvel = 0.0
   vnp = sface
   vnm = sface
   CALL PUSHINTEGER4(1)
   ELSE
   CALL PUSHINTEGER4(0)
   END IF
   ! Incorporate porFlux in porVel.
   porvel = porvel*porflux
   CALL PUSHREAL8(qsp)
   ! Compute the normal velocities relative to the grid for
   ! the face as well as the mass fluxes.
   qsp = (vnp-sface)*porvel
   CALL PUSHREAL8(qsm)
   qsm = (vnm-sface)*porvel
   CALL PUSHREAL8(rqsp)
   rqsp = qsp*wadj(0, 0, kk+1, irho, sps)
   CALL PUSHREAL8(rqsm)
   rqsm = qsm*wadj(0, 0, kk, irho, sps)
   CALL PUSHREAL8(pa)
   ! Compute the sum of the pressure multiplied by porFlux.
   ! For the default value of porFlux, 0.5, this leads to
   ! the average pressure.
   pa = porflux*(padj(0, 0, kk+1, sps)+padj(0, 0, kk, sps))
   ! Compute the fluxes through this face.
   ! Update k and set fact to 1 for the second face.
   k = k + 1
   CALL PUSHREAL8(fact)
   fact = one
   END DO
   ! Add the rotational source terms for a moving block in a
   ! steady state computation. These source terms account for the
   ! centrifugal acceleration and the coriolis term. However, as
   ! the equations are solved in the inertial frame and not
   ! in the moving frame, the form is different than what you
   ! normally find in a text book.
   IF (blockismoving .AND. equationmode .EQ. steady) THEN
   !          wx = timeRef*rotRateAdj(1)
   !          wy = timeRef*rotRateAdj(2)
   !          wz = timeRef*rotRateAdj(3)
   !timeref is taken into account in copyAdjointStencil...
   wx = rotrateadj(1)
   wy = rotrateadj(2)
   wz = rotrateadj(3)
   rvol = wadj(0, 0, 0, irho, sps)*voladj(0, 0, 0, sps)
   tempb2 = rvol*dwadjb(imz, sps)
   rvolb = (wy*wadj(0, 0, 0, ivz, sps)-wz*wadj(0, 0, 0, ivy, sps))*&
   &      dwadjb(imx, sps) + (wz*wadj(0, 0, 0, ivx, sps)-wx*wadj(0, 0, 0, &
   &      ivz, sps))*dwadjb(imy, sps) + (wx*wadj(0, 0, 0, ivy, sps)-wy*wadj&
   &      (0, 0, 0, ivx, sps))*dwadjb(imz, sps)
   tempb3 = rvol*dwadjb(imy, sps)
   wxb = wadj(0, 0, 0, ivy, sps)*tempb2 - wadj(0, 0, 0, ivz, sps)*&
   &      tempb3
   wadjb(0, 0, 0, ivy, sps) = wadjb(0, 0, 0, ivy, sps) + wx*tempb2
   tempb4 = rvol*dwadjb(imx, sps)
   wyb = wadj(0, 0, 0, ivz, sps)*tempb4 - wadj(0, 0, 0, ivx, sps)*&
   &      tempb2
   wadjb(0, 0, 0, ivx, sps) = wadjb(0, 0, 0, ivx, sps) + wz*tempb3 - wy&
   &      *tempb2
   wzb = wadj(0, 0, 0, ivx, sps)*tempb3 - wadj(0, 0, 0, ivy, sps)*&
   &      tempb4
   wadjb(0, 0, 0, ivz, sps) = wadjb(0, 0, 0, ivz, sps) + wy*tempb4 - wx&
   &      *tempb3
   wadjb(0, 0, 0, ivy, sps) = wadjb(0, 0, 0, ivy, sps) - wz*tempb4
   wadjb(0, 0, 0, irho, sps) = wadjb(0, 0, 0, irho, sps) + voladj(0, 0&
   &      , 0, sps)*rvolb
   voladjb(0, 0, 0, sps) = voladjb(0, 0, 0, sps) + wadj(0, 0, 0, irho, &
   &      sps)*rvolb
   rotrateadjb(1:3) = 0.0
   rotrateadjb(3) = wzb
   rotrateadjb(2) = rotrateadjb(2) + wyb
   rotrateadjb(1) = rotrateadjb(1) + wxb
   ELSE
   rotrateadjb(1:3) = 0.0
   END IF
   sfacekadjb(-2:2, -2:2, -2:2, 1:ntimeintervalsspectral) = 0.0
   skadjb(-3:2, -3:2, -3:2, 1:3, 1:ntimeintervalsspectral) = 0.0
   sfaceb = 0.0
   DO kk=0,-1,-1
   CALL POPREAL8(fact)
   fsb = fact*dwadjb(irhoe, sps)
   tempb1 = porflux*fsb
   qspb = wadj(0, 0, kk+1, irhoe, sps)*fsb
   wadjb(0, 0, kk+1, irhoe, sps) = wadjb(0, 0, kk+1, irhoe, sps) + qsp*&
   &      fsb
   qsmb = wadj(0, 0, kk, irhoe, sps)*fsb
   wadjb(0, 0, kk, irhoe, sps) = wadjb(0, 0, kk, irhoe, sps) + qsm*fsb
   fsb = fact*dwadjb(imz, sps)
   rqspb = wadj(0, 0, kk+1, ivz, sps)*fsb
   wadjb(0, 0, kk+1, ivz, sps) = wadjb(0, 0, kk+1, ivz, sps) + rqsp*fsb
   rqsmb = wadj(0, 0, kk, ivz, sps)*fsb
   wadjb(0, 0, kk, ivz, sps) = wadjb(0, 0, kk, ivz, sps) + rqsm*fsb
   pab = skadj(0, 0, kk, 3, sps)*fsb
   skadjb(0, 0, kk, 3, sps) = skadjb(0, 0, kk, 3, sps) + pa*fsb
   fsb = fact*dwadjb(imy, sps)
   rqspb = rqspb + wadj(0, 0, kk+1, ivy, sps)*fsb
   wadjb(0, 0, kk+1, ivy, sps) = wadjb(0, 0, kk+1, ivy, sps) + rqsp*fsb
   rqsmb = rqsmb + wadj(0, 0, kk, ivy, sps)*fsb
   wadjb(0, 0, kk, ivy, sps) = wadjb(0, 0, kk, ivy, sps) + rqsm*fsb
   pab = pab + skadj(0, 0, kk, 2, sps)*fsb
   skadjb(0, 0, kk, 2, sps) = skadjb(0, 0, kk, 2, sps) + pa*fsb
   fsb = fact*dwadjb(imx, sps)
   rqspb = rqspb + wadj(0, 0, kk+1, ivx, sps)*fsb
   wadjb(0, 0, kk+1, ivx, sps) = wadjb(0, 0, kk+1, ivx, sps) + rqsp*fsb
   rqsmb = rqsmb + wadj(0, 0, kk, ivx, sps)*fsb
   wadjb(0, 0, kk, ivx, sps) = wadjb(0, 0, kk, ivx, sps) + rqsm*fsb
   pab = pab + skadj(0, 0, kk, 1, sps)*fsb
   skadjb(0, 0, kk, 1, sps) = skadjb(0, 0, kk, 1, sps) + pa*fsb
   fsb = fact*dwadjb(irho, sps)
   rqspb = rqspb + fsb
   qspb = qspb + wadj(0, 0, kk+1, irho, sps)*rqspb
   vnpb = porvel*qspb + padj(0, 0, kk+1, sps)*tempb1
   padjb(0, 0, kk+1, sps) = padjb(0, 0, kk+1, sps) + vnp*tempb1
   rqsmb = rqsmb + fsb
   qsmb = qsmb + wadj(0, 0, kk, irho, sps)*rqsmb
   vnmb = porvel*qsmb + padj(0, 0, kk, sps)*tempb1
   padjb(0, 0, kk, sps) = padjb(0, 0, kk, sps) + vnm*tempb1
   CALL POPREAL8(pa)
   padjb(0, 0, kk+1, sps) = padjb(0, 0, kk+1, sps) + porflux*pab
   padjb(0, 0, kk, sps) = padjb(0, 0, kk, sps) + porflux*pab
   CALL POPREAL8(rqsm)
   wadjb(0, 0, kk, irho, sps) = wadjb(0, 0, kk, irho, sps) + qsm*rqsmb
   CALL POPREAL8(rqsp)
   wadjb(0, 0, kk+1, irho, sps) = wadjb(0, 0, kk+1, irho, sps) + qsp*&
   &      rqspb
   CALL POPREAL8(qsm)
   sfaceb = sfaceb - porvel*qspb - porvel*qsmb
   CALL POPREAL8(qsp)
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 1) THEN
   sfaceb = sfaceb + vnpb + vnmb
   vnmb = 0.0
   vnpb = 0.0
   END IF
   CALL POPINTEGER4(branch)
   CALL POPREAL8(porflux)
   CALL POPREAL8(porvel)
   CALL POPREAL8(vnm)
   wadjb(0, 0, kk, ivx, sps) = wadjb(0, 0, kk, ivx, sps) + skadj(0, 0, &
   &      kk, 1, sps)*vnmb
   skadjb(0, 0, kk, 1, sps) = skadjb(0, 0, kk, 1, sps) + wadj(0, 0, kk&
   &      , ivx, sps)*vnmb
   wadjb(0, 0, kk, ivy, sps) = wadjb(0, 0, kk, ivy, sps) + skadj(0, 0, &
   &      kk, 2, sps)*vnmb
   skadjb(0, 0, kk, 2, sps) = skadjb(0, 0, kk, 2, sps) + wadj(0, 0, kk&
   &      , ivy, sps)*vnmb
   wadjb(0, 0, kk, ivz, sps) = wadjb(0, 0, kk, ivz, sps) + skadj(0, 0, &
   &      kk, 3, sps)*vnmb
   skadjb(0, 0, kk, 3, sps) = skadjb(0, 0, kk, 3, sps) + wadj(0, 0, kk&
   &      , ivz, sps)*vnmb
   CALL POPREAL8(vnp)
   wadjb(0, 0, kk+1, ivx, sps) = wadjb(0, 0, kk+1, ivx, sps) + skadj(0&
   &      , 0, kk, 1, sps)*vnpb
   skadjb(0, 0, kk, 1, sps) = skadjb(0, 0, kk, 1, sps) + wadj(0, 0, kk+&
   &      1, ivx, sps)*vnpb
   wadjb(0, 0, kk+1, ivy, sps) = wadjb(0, 0, kk+1, ivy, sps) + skadj(0&
   &      , 0, kk, 2, sps)*vnpb
   skadjb(0, 0, kk, 2, sps) = skadjb(0, 0, kk, 2, sps) + wadj(0, 0, kk+&
   &      1, ivy, sps)*vnpb
   wadjb(0, 0, kk+1, ivz, sps) = wadjb(0, 0, kk+1, ivz, sps) + skadj(0&
   &      , 0, kk, 3, sps)*vnpb
   skadjb(0, 0, kk, 3, sps) = skadjb(0, 0, kk, 3, sps) + wadj(0, 0, kk+&
   &      1, ivz, sps)*vnpb
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 1) THEN
   sfacekadjb(0, 0, kk, sps) = sfacekadjb(0, 0, kk, sps) + sfaceb
   sfaceb = 0.0
   END IF
   END DO
   sfacejadjb(-2:2, -2:2, -2:2, 1:ntimeintervalsspectral) = 0.0
   sjadjb(-3:2, -3:2, -3:2, 1:3, 1:ntimeintervalsspectral) = 0.0
   DO jj=0,-1,-1
   CALL POPREAL8(fact)
   fsb = fact*dwadjb(irhoe, sps)
   tempb0 = porflux*fsb
   qspb = wadj(0, jj+1, 0, irhoe, sps)*fsb
   wadjb(0, jj+1, 0, irhoe, sps) = wadjb(0, jj+1, 0, irhoe, sps) + qsp*&
   &      fsb
   qsmb = wadj(0, jj, 0, irhoe, sps)*fsb
   wadjb(0, jj, 0, irhoe, sps) = wadjb(0, jj, 0, irhoe, sps) + qsm*fsb
   fsb = fact*dwadjb(imz, sps)
   rqspb = wadj(0, jj+1, 0, ivz, sps)*fsb
   wadjb(0, jj+1, 0, ivz, sps) = wadjb(0, jj+1, 0, ivz, sps) + rqsp*fsb
   rqsmb = wadj(0, jj, 0, ivz, sps)*fsb
   wadjb(0, jj, 0, ivz, sps) = wadjb(0, jj, 0, ivz, sps) + rqsm*fsb
   pab = sjadj(0, jj, 0, 3, sps)*fsb
   sjadjb(0, jj, 0, 3, sps) = sjadjb(0, jj, 0, 3, sps) + pa*fsb
   fsb = fact*dwadjb(imy, sps)
   rqspb = rqspb + wadj(0, jj+1, 0, ivy, sps)*fsb
   wadjb(0, jj+1, 0, ivy, sps) = wadjb(0, jj+1, 0, ivy, sps) + rqsp*fsb
   rqsmb = rqsmb + wadj(0, jj, 0, ivy, sps)*fsb
   wadjb(0, jj, 0, ivy, sps) = wadjb(0, jj, 0, ivy, sps) + rqsm*fsb
   pab = pab + sjadj(0, jj, 0, 2, sps)*fsb
   sjadjb(0, jj, 0, 2, sps) = sjadjb(0, jj, 0, 2, sps) + pa*fsb
   fsb = fact*dwadjb(imx, sps)
   rqspb = rqspb + wadj(0, jj+1, 0, ivx, sps)*fsb
   wadjb(0, jj+1, 0, ivx, sps) = wadjb(0, jj+1, 0, ivx, sps) + rqsp*fsb
   rqsmb = rqsmb + wadj(0, jj, 0, ivx, sps)*fsb
   wadjb(0, jj, 0, ivx, sps) = wadjb(0, jj, 0, ivx, sps) + rqsm*fsb
   pab = pab + sjadj(0, jj, 0, 1, sps)*fsb
   sjadjb(0, jj, 0, 1, sps) = sjadjb(0, jj, 0, 1, sps) + pa*fsb
   fsb = fact*dwadjb(irho, sps)
   rqspb = rqspb + fsb
   qspb = qspb + wadj(0, jj+1, 0, irho, sps)*rqspb
   vnpb = porvel*qspb + padj(0, jj+1, 0, sps)*tempb0
   padjb(0, jj+1, 0, sps) = padjb(0, jj+1, 0, sps) + vnp*tempb0
   rqsmb = rqsmb + fsb
   qsmb = qsmb + wadj(0, jj, 0, irho, sps)*rqsmb
   vnmb = porvel*qsmb + padj(0, jj, 0, sps)*tempb0
   padjb(0, jj, 0, sps) = padjb(0, jj, 0, sps) + vnm*tempb0
   CALL POPREAL8(pa)
   padjb(0, jj+1, 0, sps) = padjb(0, jj+1, 0, sps) + porflux*pab
   padjb(0, jj, 0, sps) = padjb(0, jj, 0, sps) + porflux*pab
   CALL POPREAL8(rqsm)
   wadjb(0, jj, 0, irho, sps) = wadjb(0, jj, 0, irho, sps) + qsm*rqsmb
   CALL POPREAL8(rqsp)
   wadjb(0, jj+1, 0, irho, sps) = wadjb(0, jj+1, 0, irho, sps) + qsp*&
   &      rqspb
   CALL POPREAL8(qsm)
   sfaceb = sfaceb - porvel*qspb - porvel*qsmb
   CALL POPREAL8(qsp)
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 1) THEN
   sfaceb = sfaceb + vnpb + vnmb
   vnmb = 0.0
   vnpb = 0.0
   END IF
   CALL POPINTEGER4(branch)
   CALL POPREAL8(porflux)
   CALL POPREAL8(porvel)
   CALL POPREAL8(vnm)
   wadjb(0, jj, 0, ivx, sps) = wadjb(0, jj, 0, ivx, sps) + sjadj(0, jj&
   &      , 0, 1, sps)*vnmb
   sjadjb(0, jj, 0, 1, sps) = sjadjb(0, jj, 0, 1, sps) + wadj(0, jj, 0&
   &      , ivx, sps)*vnmb
   wadjb(0, jj, 0, ivy, sps) = wadjb(0, jj, 0, ivy, sps) + sjadj(0, jj&
   &      , 0, 2, sps)*vnmb
   sjadjb(0, jj, 0, 2, sps) = sjadjb(0, jj, 0, 2, sps) + wadj(0, jj, 0&
   &      , ivy, sps)*vnmb
   wadjb(0, jj, 0, ivz, sps) = wadjb(0, jj, 0, ivz, sps) + sjadj(0, jj&
   &      , 0, 3, sps)*vnmb
   sjadjb(0, jj, 0, 3, sps) = sjadjb(0, jj, 0, 3, sps) + wadj(0, jj, 0&
   &      , ivz, sps)*vnmb
   CALL POPREAL8(vnp)
   wadjb(0, jj+1, 0, ivx, sps) = wadjb(0, jj+1, 0, ivx, sps) + sjadj(0&
   &      , jj, 0, 1, sps)*vnpb
   sjadjb(0, jj, 0, 1, sps) = sjadjb(0, jj, 0, 1, sps) + wadj(0, jj+1, &
   &      0, ivx, sps)*vnpb
   wadjb(0, jj+1, 0, ivy, sps) = wadjb(0, jj+1, 0, ivy, sps) + sjadj(0&
   &      , jj, 0, 2, sps)*vnpb
   sjadjb(0, jj, 0, 2, sps) = sjadjb(0, jj, 0, 2, sps) + wadj(0, jj+1, &
   &      0, ivy, sps)*vnpb
   wadjb(0, jj+1, 0, ivz, sps) = wadjb(0, jj+1, 0, ivz, sps) + sjadj(0&
   &      , jj, 0, 3, sps)*vnpb
   sjadjb(0, jj, 0, 3, sps) = sjadjb(0, jj, 0, 3, sps) + wadj(0, jj+1, &
   &      0, ivz, sps)*vnpb
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 1) THEN
   sfacejadjb(0, jj, 0, sps) = sfacejadjb(0, jj, 0, sps) + sfaceb
   sfaceb = 0.0
   END IF
   END DO
   sfaceiadjb(-2:2, -2:2, -2:2, 1:ntimeintervalsspectral) = 0.0
   siadjb(-3:2, -3:2, -3:2, 1:3, 1:ntimeintervalsspectral) = 0.0
   DO ii=0,-1,-1
   CALL POPREAL8(fact)
   fsb = fact*dwadjb(irhoe, sps)
   tempb = porflux*fsb
   qspb = wadj(ii+1, 0, 0, irhoe, sps)*fsb
   wadjb(ii+1, 0, 0, irhoe, sps) = wadjb(ii+1, 0, 0, irhoe, sps) + qsp*&
   &      fsb
   qsmb = wadj(ii, 0, 0, irhoe, sps)*fsb
   wadjb(ii, 0, 0, irhoe, sps) = wadjb(ii, 0, 0, irhoe, sps) + qsm*fsb
   fsb = fact*dwadjb(imz, sps)
   rqspb = wadj(ii+1, 0, 0, ivz, sps)*fsb
   wadjb(ii+1, 0, 0, ivz, sps) = wadjb(ii+1, 0, 0, ivz, sps) + rqsp*fsb
   rqsmb = wadj(ii, 0, 0, ivz, sps)*fsb
   wadjb(ii, 0, 0, ivz, sps) = wadjb(ii, 0, 0, ivz, sps) + rqsm*fsb
   pab = siadj(ii, 0, 0, 3, sps)*fsb
   siadjb(ii, 0, 0, 3, sps) = siadjb(ii, 0, 0, 3, sps) + pa*fsb
   fsb = fact*dwadjb(imy, sps)
   rqspb = rqspb + wadj(ii+1, 0, 0, ivy, sps)*fsb
   wadjb(ii+1, 0, 0, ivy, sps) = wadjb(ii+1, 0, 0, ivy, sps) + rqsp*fsb
   rqsmb = rqsmb + wadj(ii, 0, 0, ivy, sps)*fsb
   wadjb(ii, 0, 0, ivy, sps) = wadjb(ii, 0, 0, ivy, sps) + rqsm*fsb
   pab = pab + siadj(ii, 0, 0, 2, sps)*fsb
   siadjb(ii, 0, 0, 2, sps) = siadjb(ii, 0, 0, 2, sps) + pa*fsb
   fsb = fact*dwadjb(imx, sps)
   rqspb = rqspb + wadj(ii+1, 0, 0, ivx, sps)*fsb
   wadjb(ii+1, 0, 0, ivx, sps) = wadjb(ii+1, 0, 0, ivx, sps) + rqsp*fsb
   rqsmb = rqsmb + wadj(ii, 0, 0, ivx, sps)*fsb
   wadjb(ii, 0, 0, ivx, sps) = wadjb(ii, 0, 0, ivx, sps) + rqsm*fsb
   pab = pab + siadj(ii, 0, 0, 1, sps)*fsb
   siadjb(ii, 0, 0, 1, sps) = siadjb(ii, 0, 0, 1, sps) + pa*fsb
   fsb = fact*dwadjb(irho, sps)
   rqspb = rqspb + fsb
   qspb = qspb + wadj(ii+1, 0, 0, irho, sps)*rqspb
   vnpb = porvel*qspb + padj(ii+1, 0, 0, sps)*tempb
   padjb(ii+1, 0, 0, sps) = padjb(ii+1, 0, 0, sps) + vnp*tempb
   rqsmb = rqsmb + fsb
   qsmb = qsmb + wadj(ii, 0, 0, irho, sps)*rqsmb
   vnmb = porvel*qsmb + padj(ii, 0, 0, sps)*tempb
   padjb(ii, 0, 0, sps) = padjb(ii, 0, 0, sps) + vnm*tempb
   CALL POPREAL8(pa)
   padjb(ii+1, 0, 0, sps) = padjb(ii+1, 0, 0, sps) + porflux*pab
   padjb(ii, 0, 0, sps) = padjb(ii, 0, 0, sps) + porflux*pab
   CALL POPREAL8(rqsm)
   wadjb(ii, 0, 0, irho, sps) = wadjb(ii, 0, 0, irho, sps) + qsm*rqsmb
   CALL POPREAL8(rqsp)
   wadjb(ii+1, 0, 0, irho, sps) = wadjb(ii+1, 0, 0, irho, sps) + qsp*&
   &      rqspb
   CALL POPREAL8(qsm)
   sfaceb = sfaceb - porvel*qspb - porvel*qsmb
   CALL POPREAL8(qsp)
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 1) THEN
   sfaceb = sfaceb + vnpb + vnmb
   vnmb = 0.0
   vnpb = 0.0
   END IF
   CALL POPINTEGER4(branch)
   CALL POPREAL8(porflux)
   CALL POPREAL8(porvel)
   CALL POPREAL8(vnm)
   wadjb(ii, 0, 0, ivx, sps) = wadjb(ii, 0, 0, ivx, sps) + siadj(ii, 0&
   &      , 0, 1, sps)*vnmb
   siadjb(ii, 0, 0, 1, sps) = siadjb(ii, 0, 0, 1, sps) + wadj(ii, 0, 0&
   &      , ivx, sps)*vnmb
   wadjb(ii, 0, 0, ivy, sps) = wadjb(ii, 0, 0, ivy, sps) + siadj(ii, 0&
   &      , 0, 2, sps)*vnmb
   siadjb(ii, 0, 0, 2, sps) = siadjb(ii, 0, 0, 2, sps) + wadj(ii, 0, 0&
   &      , ivy, sps)*vnmb
   wadjb(ii, 0, 0, ivz, sps) = wadjb(ii, 0, 0, ivz, sps) + siadj(ii, 0&
   &      , 0, 3, sps)*vnmb
   siadjb(ii, 0, 0, 3, sps) = siadjb(ii, 0, 0, 3, sps) + wadj(ii, 0, 0&
   &      , ivz, sps)*vnmb
   CALL POPREAL8(vnp)
   wadjb(ii+1, 0, 0, ivx, sps) = wadjb(ii+1, 0, 0, ivx, sps) + siadj(ii&
   &      , 0, 0, 1, sps)*vnpb
   siadjb(ii, 0, 0, 1, sps) = siadjb(ii, 0, 0, 1, sps) + wadj(ii+1, 0, &
   &      0, ivx, sps)*vnpb
   wadjb(ii+1, 0, 0, ivy, sps) = wadjb(ii+1, 0, 0, ivy, sps) + siadj(ii&
   &      , 0, 0, 2, sps)*vnpb
   siadjb(ii, 0, 0, 2, sps) = siadjb(ii, 0, 0, 2, sps) + wadj(ii+1, 0, &
   &      0, ivy, sps)*vnpb
   wadjb(ii+1, 0, 0, ivz, sps) = wadjb(ii+1, 0, 0, ivz, sps) + siadj(ii&
   &      , 0, 0, 3, sps)*vnpb
   siadjb(ii, 0, 0, 3, sps) = siadjb(ii, 0, 0, 3, sps) + wadj(ii+1, 0, &
   &      0, ivz, sps)*vnpb
   CALL POPINTEGER4(branch)
   IF (.NOT.branch .LT. 1) THEN
   sfaceiadjb(ii, 0, 0, sps) = sfaceiadjb(ii, 0, 0, sps) + sfaceb
   sfaceb = 0.0
   END IF
   END DO
   END SUBROUTINE INVISCIDCENTRALFLUXADJTS_B