clear all
set more off
cd "C:\Users\maart\Desktop\Nicolas\Eco Ambiental y Espacial\TP2"

/*
import delimited "engho2018_hogares.txt", delimiter( “|”) clear
save "engho2018_hogares.dta", replace
import delimited "engho2018_gastos.txt", delimiter( “|”) clear
save "engho2018_gastos.dta", replace
*/

import delimited "engho2018_hogares.txt", delimiter ("|")
save "engho2018_hogares.dta", replace

clear all

import delimited "engho2018_gastos.txt", delimiter ("|")
save "engho2018_gastos.dta", replace

use "engho2018_hogares.dta", clear
merge 1:m id using "engho2018_gastos.dta"

* Generamos una variable que nos refleje el gasto en alquiler de la vivienda de uso permanente (incluye el gasto de habitación de pensión, hotel, casa de familia, etc.)
gen alquiler= monto if articulo=="A0411101"
*Dejamos fuera de nuestra variable creada 66 hogares que reportan gastos de alquiler pero que no son inquilinos
replace alquiler = . if articulo=="A0411101" & regten!=2

*Buscamos que Stata nos refleje el alquiler del hogar en base al jefe de hogar, ya que, de no hacerlo así, podríamos quedarnos con un missing porque selecciono cualquier integrante del hogar.
egen alquiler_hog= max(alquiler), by(id)

*La variable alquiler ya no nos sirve por lo tanto la elimino y renombro la variable de alquiler en base al jefe de hogar como la nueva de alquiler
drop alquiler
rename alquiler_hog alquiler

*Elimino también a los ocupantes de la muestra dado que para el trabajo necesitamos únicamente a los inquilinos y propietarios
drop if regten==3

*Una vez que eliminamos a los ocupantes de la base, obtenemos el promedio de alquiler para los inquilinos y los propietarios. En particular los inquilinos dado que los propietarios no alquilan
table regten, c(mean alquiler)

* Ordenamos la muestra en base al hogar y los miembros del hogar
sort id miembro
* Ahora creamos una variable que nos sume la cantidad de personas en el hogar y le vamos a pedir a Stata que se quede con aquellos que tienen un valor de 1 para obtener una sola observación por hogar.
by id: gen tag=sum(1)
keep if tag==1
drop if regten==2 & alquiler==.

*Ahora como buscamos estimar los efectos sobre el precio que tienen diferentes características de la vivienda, nos quedamos únicamente con aquellas variables que son relevantes para nuestro ejercicio.
keep id pondera region regten ch08 ch14 ch07 ch15 cv1c09 cv1c07 cv1c13 cv1c05_a cv1c05_b cv1c05_c cv1c05_d ch05 ch13 ch21 cv1c04 ///
cantmiem jedad_agrup jsexo jniveled tipohog alquiler dinpch_t ingtoth

*Trabajaremos con las variables que nos quedamos en la muestra generando nuevas a partir de ellas para una mayor comprensión a la hora de realizar el trabajo.

* La variable ch08 refleja el sistema de red de agua que posee la persona. En nuestro caso nos interesa saber si la persona tiene agua de red.
gen agua_red=0 if ch08!=.
replace agua_red=1 if ch08==1

* La variable ch14 describe el tipo de desagüe con el que cuenta la persona. En nuestro caso nos interesa si la persona cuenta con red cloacal.
gen cloaca=0 if ch14!=.
replace cloaca=1 if ch14==1

* CH07 nos reflejará como se provee electricidad el hogar. En nuestro caso nos interesa que tenga luz de alguna forma
gen luz=0 if ch07!=.
replace luz=1 if ch07==1 | ch07==2 | ch07==3

*ch15 describe con que elemento cocina la persona. En nuestro caso, utilizaremos esta variable para saber si en la casa hay red de gas
gen gas=0 if ch15!=.
replace gas=1 if ch15==1

*cv1c04 lo utilizaremos para saber el tipo de vivienda.
rename cv1c04 tipo_viv

*Construimos una variable que nos refleje si los materiales son precarios
gen mat_prec=1 if (cv1c09>=3 & cv1c09<=4) |  (cv1c07>=6 & cv1c07<=7)
replace mat_prec=0 if  (cv1c09>=1 & cv1c09<=2) & (cv1c07>=1 & cv1c07<=5)

*Con cv1c13 sabremos la antiguedad de la vivienda
rename cv1c13 antig

* Construimos una variable que nos indique si la vivienda posee cochera
gen cochera=0 if cv1c05_a!=.
replace cochera=1 if cv1c05_a==1 | cv1c05_a==2

* Construimos la variable para saber si la vivienda tiene jardín
gen jardin=0 if cv1c05_b!=.
replace jardin=1 if cv1c05_b==1 | cv1c05_b==2

* Generamos una variable que nos indique si la vivienda cuenta con piscina
gen piscina=0 if cv1c05_c!=.
replace piscina=1 if cv1c05_c==1 | cv1c05_c==2

* Generamos una variable que nos refleje si la vivienda cuenta con un área deportiva
gen area_depor=0 if cv1c05_d!=.
replace area_depor=1 if cv1c05_d==1 | cv1c05_d==2

* Creamos una variable que nos distinga la cantidad de ambientes del hogar
rename ch05 cant_amb

* Creamos una variable que nos refleje la cantidad de baños de la vivienda
rename ch13 cant_ban

* Finalmente, una variable que nos refleje si cuenta la vivienda con aire acondicionado
gen air_acon=0 if ch21!=.
replace air_acon=1 if ch21==1

save "ENGHO2018paraTP.dta", replace

use "ENGHO2018paraTP.dta", clear
*Dado que ya generamos todas las variables necesarias para estimar lo que se nos pide en el ejercicio, empezamos creando el logaritmo del alquiler para una mejor interpretación de la regresión

gen lalquiler=ln(alquiler)

*Estimamos nuestro modelo
reg lalquiler agua_red cloaca luz gas i.tipo_viv mat_prec antig cochera jardin piscina area_depor cant_amb cant_ban air_acon i.region, robust

*Creamos una variable que nos permita mantener el valor estimado dadas las caracterísitcas del hogar para poder comparar en el inciso 3 el valor estimado con el valor efectivo que pago
predict lalquiler_pred

*** Inciso 3 ****
* Generamos una variable que nos refleje la diferencia entre el alquiler efectivamente pagado y el alquiler estimado
gen dif_alquiler= lalquiler-lalquiler_pred

* Ahora, buscamos saber para cada décil del ingreso cuanto pago en promedio efectivamente, cuanto debería haber pagado según las características del hogar en promedio y cuanto fue la diferencia en promedio entre el pago efectivo y el estimado
table dinpch_t, c(mean lalquiler mean lalquiler_pred mean dif_alquiler) row




*/
*-------------------------------------------------------------------------------------------------------------------------------------------*
* 	------------------------------				EJERCICIO 2 			--------------------------------------------------------------		*				
*-------------------------------------------------------------------------------------------------------------------------------------------*
*/
use "ENGHO2018paraTP.dta", clear
*TRABAJAMOS CON LA VARIABLE EN LOGARITMO*

gen lalquiler=log(alquiler)
*******categorizacion de regresores en ENGHO*
local hogar "cantmiem jniveled jsexo jedad_agrup tipohog"
local vivienda "cant_amb mat_prec agua_red cant_ban cloaca luz"
local region "region2 region3 region4 region5"
/*Variables en ENGHO: 1. Régimen de tenencia: 1) proopietario; 2) inquilino; 3) ocupante y otros
A NIVEL DE HOGAR:
1. Miembros: cantmiem
2. Nivel educativo jefe
3. Sexo jefe
4. Edad agrupada del jefe de hogar
5. Tipo de hogar: tipohog (unipersonal, nuclear, etc)

A NIVEL DE VIVIENDA:
1. Ambientes: nro de ambientes de uso exclusivo tiene este
2. Materiales precarios
3. Agua_red	
4. Baños: nro de baños de uso exclusivo
5. Cloaca 
6. Luz

OTROS: dummies regionales
*/

* Dummies por region
tab region, gen(region)



*Genero ingreso per cápita sin renta (ingreso total del hogar dividio variable de cantidad de miembros)
gen ipcf_sin_ri = ingtoth/cantmiem

* Genera deciles del ipcf antes de imputar renta implicita
include cuantiles.do
* genero es este caso deciles*
cuantiles ipcf_sin_ri [w=pondera], n(10) gen(decil_sin_ri)

********************* Regresión por cuantiles para inquilinos:
*Hacemos la regresión por deciles
forvalues d = 1(1)10	{
			loc decil = `d'/(10+1)
		*realizo la regresion en funcion de las locales*
			qreg lalquiler `hogar' `vivienda' `region' if regten==2, q(`decil')
			*guardo los coeficientes en matriz
			mat beta_d`d' = e(b)
	}	
			
************************* *Proyectamos el alquiler en los propietarios para cada decil

forvalues d = 1(1)10	{
			if `d'==1 mat score  lalquiler_qr = beta_d`d'	if  decil_sin_ri==`d' 
			if `d'!=1 mat score  lalquiler_qr= beta_d`d'	if  decil_sin_ri==`d' , replace
	}		
	
	

*Ajustamos por outliers (eliminamos el p99 de cada decil,ya que son valores muy altos y los mismos me generan ruido)
preserve
forvalues d= 1(1)10 {
sum lalquiler_qr if decil_sin_ri==`d', detail
drop if lalquiler_qr>=r(p99) & decil_sin_ri==`d'
}
restore
* Imputación de los coeficientes de la regresión: construyo renta implícita
gen	renta_imp = exp(lalquiler_qr)

*Imputación de renta a los propietarios
gen ingtoth_con_ri = ingtoth + renta_imp if regten==1
gen ipcf_con_ri = ingtoth_con_ri/cantmiem if regten==1

**************************Renta implícita por deciles
graph bar renta_imp, over(decil_sin_ri)
graph bar ipcf_sin_ri ipcf_con_ri, over(decil_sin_ri)

*Ratios sin renta implícita
summ ipcf_sin_ri,detail
local p10_sinri=r(p10)
local p90_sinri=r(p90)



*Ratios con renta implícita
summ ipcf_con_ri,detail
local p10_conri=r(p10)
local p90_conri=r(p90)


dis in yellow "Ratio p90/p10 sin renta implícita=" `p90_sinri'/`p10_sinri' 

dis in yellow "Ratio p90/p10 con renta implícita="  `p90_conri'/`p10_conri'



