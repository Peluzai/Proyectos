clear all

capture cd "C:\Users\itachi\Desktop\Pelusa\Stata 16-20220622T205402Z-001\Stata 16\Econometria 2"

set more off
set dp comma

import excel "BaseFinal", firstrow
************************
* Establecemos la serie de tiempo
gen mes=mofd(Fecha)
format %tmMon-YY mes
tsset mes, monthly
drop Fecha
order mes
label var mes "Mes"
************************


*****************************************************************
********************* PUNTO 1 **********************************
*****************************************************************
/*GENERAMOS LAS VARIABLES EN LOGARITMOS Y EN DIFERENCIAS DE LOGARITMOS
BUSCAMOS OBSERVAR SI EXISTE COMPORTAMIENTO ESTACIONAL
*/

*LOGARITMO DEL IPC Y DIFERENCIA DEL LOGARITMO DEL IPC
gen lIPC=ln(IPC)
dfsummary lIPC, trend seasonal reg

*No es estacional, todos las dummies seasonals son no significativas al 1%

gen D_lIPC= (ln(IPC) - ln(L.IPC))
label var D_lIPC "IPC en dif"

*LOGARITMO DEL EMAE Y DIFERENCIA DEL LOGARITMO DEL EMAE

gen lEMAE=ln(EMAE)

dfsummary lEMAE, trend seasonal reg

*No es estacional, todos las dummies seasonals son no significativas al 1%
*Usamos la serie del EMAE del indec desestacionalizada

gen D_lEMAE = (ln(EMAE) - ln(L.EMAE))
label var D_lEMAE "EMAE en dif"

*LOGARITMO DEL TCN Y DIFERENCIA DEL LOGARITMO DEL TCN

gen lTCN = ln(TCN)
dfsummary lTCN, trend seasonal reg

*No es estacional, todos las dummies seasonals son no significativas al 1%

gen D_lTCN= (ln(TCN) - ln(L.TCN))
label var D_lTCN "TCN en dif"

*LOGARITMO DEL RIPTE Y DIFERENCIA DEL LOGARITMO DEL RIPTE

gen lRIPTE=ln(RIPTE)
dfsummary lRIPTE, trend seasonal reg

*Es estacional, tres dummies seasonals significativas al 1%, entonces desestacionalizamos la serie

tssmooth ma slRIPTE=lRIPTE , window(12 1 12)
gen D_slRIPTE= (slRIPTE - L.slRIPTE)
label var D_slRIPTE "RIPTE en dif suavizado"
gen D_lRIPTE= D.lRIPTE
label var D_lRIPTE "RIPTE en dif"

*LOGARITMO DEL M2 Y DIFERENCIA DEL LOGARITMO DEL M2

gen lM2=ln(M2)
dfsummary lM2, trend seasonal reg

*Es estacional, dos dummies seasonals significativas al 1%, entonces desestacionalizamos la serie

tssmooth ma slM2=lM2 , window(12 1 12)
gen D_slM2= (slM2 - L.slM2)
label var D_slM2 "M2 en dif suavizado"
gen D_lM2= D.lM2
label var D_lM2 "M2 en dif"


*Para estos gráficos no usamos las series suavizadas, solo usamos las series en logaritmos y en diferncias de logaritmos

*GRÁFICOS
*tsline D.lM2 D.lRIPTE D.lTCN D.lEMAE D.lIPC , legend(label(1 "M2") label (2 "RIPTE") label (3 "TCN") label (4 "EMAE") label (5 "IPC")) xlabel(#17, angle(vertical)) ylabel(, angle(horizontal)) ytitle("Proxy del cambio porcentual")  title("Series en diferencias de logaritmos") graphregion(color(white)) note("Nota: Elaboración propia en base a INDEC, BCRA, Min. Trabajo")
*graph export "Pto1_diferencias.png", replace

*tsline lM2 lRIPTE lTCN lEMAE lIPC, legend(label(1 "M2") label (2 "RIPTE") label (3 "TCN") label (4 "EMAE") label (5 "IPC")) xlabel(#17, angle(vertical)) title("Series en logaritmos") ylabel(, angle(horizontal)) ytitle("Logaritmos") graphregion(color(white)) note("Nota: Elaboración propia en base a INDEC, BCRA, Min. Trabajo")
*graph export "Pto1_ln.png", replace


*****************************************************************
********************* PUNTO 2 **********************************
*****************************************************************


*CONTRASTES DE CAMBIO ESTRUCTURAL PARA TODAS LAS SERIES

***NO CONOZCO H

*PARA IPC
reg D_lIPC L.D_lIPC
estat sbsingle, swald
*no rechazo nula dado que no encuentro cambio estructural
*para la constante
estat sbsingle, breakvars(, constant)
*no rechazo nula, no hay cambio estructural

*PARA TCN
reg D_lTCN L.D_lTCN
estat sbsingle, swald
*no rechazo nula, no hay cambio estructural
*para la constante
estat sbsingle, breakvars(, constant)
*no rechazo nula, no hay cambio estructural

*****PARA EMAE*****
reg D_lEMAE L.D_lEMAE
estat sbsingle, swald
*Rechazo nula, hay cambio estructural al 1% de significatividad en Mayo 2020
tsline D_lEMAE, xlabel(#17, angle(vertical)) ylabel(, angle(horizontal)) ytitle("Log del EMAE en diferencias")  title("Cambio estructural") subtitle("EMAE") graphregion(color(white)) note("Nota: Elaboración propia en base a EMAE - INDEC")
graph export "Pto2_emae.png", replace
estat sbsingle, breakvars(, constant)
*Rechazo nula, hay cambio estructural al 10% de significatividad en Mayo 2020
estat sbsingle, generate(waldemae)  /* opciÃ³n para graficar estadÃ­sticos */
tsline waldemae, title("Estadistico Test de Wald")

****PARA RIPTE****
reg D_slRIPTE L.D_slRIPTE
estat sbsingle, swald
*Rechazo nula, hay cambio estructural al 1% de significatividad Abril 2021
tsline D_slRIPTE, xlabel(#17, angle(vertical)) ylabel(, angle(horizontal)) ytitle("Log del RIPTE en diferencias")  title("Cambio estructural") subtitle("RIPTE") graphregion(color(white)) note("Nota: Elaboración propia en base a RIPTE - Min. Trabajo")
graph export "Pto2_ripte.png", replace
estat sbsingle, breakvars(, constant)
*Rechazo nula, hay cambio estructural al 5% de significatividad Abril 2021
estat sbsingle, generate(waldripte)  /* opciÃ³n para graficar estadÃ­sticos */
tsline waldripte, title("Estadistico Test de Wald")

******PARA M2*******
reg D_slM2 L.D_slM2
estat sbsingle, swald
*Rechazo nula, hay cambio estructural al 1% de significatividad Noviembre 2020
tsline D_slM2, xlabel(#17, angle(vertical)) ylabel(, angle(horizontal)) ytitle("Log del M2 en diferencias")  title("Cambio estructural") subtitle("M2") graphregion(color(white)) note("Nota: Elaboración propia en base a M2 - BCRA")
*graph export "Pto2_M2.png", replace
estat sbsingle, breakvars(, constant)
*Rechazo nula, hay cambio estructural al 10% de significatividad Noviembre 2020
estat sbsingle, generate(waldm2)  /* opciÃ³n para graficar estadÃ­sticos */
tsline waldm, title("Estadistico Test de Wald")


*** CONOZCO H

*PARA IPC
reg D_lIPC L.D_lIPC
estat sbknown, break(tm(2020m3))
*no rechazo, no hay cambio estructural

*PARA TCN
reg D_lTCN L.D_lTCN
estat sbknown, break(tm(2020m3))
*no rechazo, no hay cambio estructural


*PARA EMAE
reg D_lEMAE L.D_lEMAE
estat sbknown, break(tm(2020m3))
*no rechazo, no hay cambio estructural

*PARA RIPTE
reg D_slRIPTE L.D_slRIPTE
estat sbknown, break(tm(2020m3))
*No rechazo, no hay cambio estructural en Marzo 2020 al 1% de significatividad
estat sbknown, break(tm(2021m4))
*Si rechazo para abril del 2021, donde hay cambio estructural al 1% de significatividad


*PARA M2
reg D_slM2 L.D_slM2
estat sbknown, break(tm(2020m3))
*No rechazo, no hay cambio estructural en Marzo 2020 al 1% de significatividad
estat sbknown, break(tm(2020m11))
*Si rechazo para no viembre del 2020, donde hay cambio estructural al 1% de significatividad



*****************************************************************
********************* PUNTO 3 **********************************
*****************************************************************

*******MODELO VAR

*Para estimar el modelo VAR en diferencias y logaritmos primero debemos saber la cantidad de rezagos a utilizar
varsoc D.lIPC D.lEMAE D.lTCN D.slRIPTE D.slM2
*Siguiendo el criterio AIC: 1 rezago para el var
var D.lIPC D.lEMAE D.lTCN D.slRIPTE D.slM2, lags(1)
*Estacionariedad
varstable, graph
*graph export "varstable.png", replace
*El modelo var es estacionario

*Autocorrelacion
varlmar, mlag(1)
*No rechazo por p valor, no tengo autocorrelacion al 10%
*Test de Causalidad de Granger
vargranger


*****************************************************************
********************* PUNTO 4 **********************************
*****************************************************************

*Supuestos:
*TCN ⇒ M2 ⇒ IPC ⇒ RIPTE ⇒ EMAE

var D.lTCN D.slM2 D.lIPC D.slRIPTE D.lEMAE, lag(1)
irf create order1, step(12) set(myIRF1, replace)

*irf graph oirf
irf graph oirf, impulse(D.slM2) response(D.lIPC) xlabel(#12) ylabel(, angle(horizontal))  title("Función de impulso respuesta") subtitle("Efecto ortogonal del M2 sobre IPC") graphregion(color(white)) note("Nota: Elaboración propia en base a BCRA - INDEC")
irf table oirf, impulse(D.slM2) response(D.lIPC)
graph export "F_Impulso_Respuesta_oirf.png", replace
irf graph oirf, impulse(D.slM2) response(D.lIPC D.slM2)
irf table oirf, impulse(D.slM2) response(D.lIPC D.slM2)


*Efecto acumulado
irf graph coirf, impulse(D.slM2) response(D.lIPC) xlabel(#12) ylabel(, angle(horizontal))  title("Función de impulso respuesta acumulada") subtitle("Efecto acumulado del M2 sobre IPC") graphregion(color(white)) note("Nota: Elaboración propia en base a BCRA - INDEC")
irf table coirf, impulse(D.slM2) response(D.lIPC)
graph export "F_Impulso_Respuesta_coirf.png", replace
irf graph coirf, impulse(D.slM2) response(D.lIPC D.slM2)  xlabel(#15) xtitle("Mes") xlabel(0(1)12) note("Fuente: ElaboraciÃ³n propia sobre base de datos de INDEC y BCRA")
irf table coirf, impulse(D.slM2) response(D.lIPC D.slM2)


*Efecto LP acumulado
*disp  .00171 /.002496
*0.68509615


*****************************************************************
********************* PUNTO 5 **********************************
*****************************************************************

*****MODELO VEC

varsoc lIPC lTCN slM2 slRIPTE lEMAE
*Control de Cointegracion: Rango
*determinar el rango de la matriz, que cantidad de vectores de cointegracion tenemos
vecrank lIPC lTCN slM2 slRIPTE lEMAE, lags(2) levela
*trabajamos al 1% de significatividad
*Estimacion VEC
vec lIPC lTCN slM2 lEMAE slRIPTE, lags(2) rank(1)
*Autocrrelacion de los residuos
veclmar
*Estabilida VEC
*ce1 es el vector de cointegracion
predict cel, ce
twoway (tsline cel)
vecstable, graph

*****************************************************************
********************* PUNTO 6 **********************************
*****************************************************************

*primero consideramos un modelo univariado
*Ya generamos linf =lIPC - (L.log_IPC)} = D_lIPC
*hago la regression*
reg D_lIPC lIPC L.lIPC lEMAE lTCN lM2 lRIPTE
ssc install qll
*evaluo el cambio estructural*
qll D_lIPC lIPC L.lIPC lEMAE lTCN lM2 lRIPTE

estat sbsingle 
*rechazo Ho y grafico*
estat sbsingle, generate(wald)
tsline wald, title("Estadistico Test de wald")






*****************************************************************
********************* PUNTO 7 **********************************
*****************************************************************

threshold lIPC, regionvars (lIPC  lM2 ) threshvar(L.lIPC) nthreshold(1)


