clear
set more off
cd "C:\Users\maart\Desktop\Nicolas\Eco Ambiental y Espacial"
use "usu_individual_T120_v13.dta"


*Empiezo cambiando las variables en mayúscula por minúscula
rename _all, lower

*Ahora tengo que trabajar con las variables para hallar el ingreso horario de la ocupación principal. Para eso debo hallar el ingreso total de la ocupación //
// y la cantidad de horas dedicadas esta semana a la ocupación principal. La variable de horas va a venir dada por pp3e_tot y la variable de ingreso total //
// va a ser p21 que representa el monto de ingreso de la ocupación principal en el mes específicado.

*Construyo la variable de salarios
gen wage=p21/(pp3e_tot*4)
replace wage=. if wage<=0
label var wage "Salario horario de la ocupación principal"

*También cambiamos el nombre de la variable ch06 por edad, ya que, ch06 representa los años cumplidos por la persona.
rename ch06 edad
replace edad=0 if edad==-1
replace edad=1 if edad==99
label var edad "edad"

*Construyo una dummy que me permita distinguir el género de la persona.
gen hombre=.
replace hombre=0 if ch04==2
replace hombre=1 if ch04==1
label var hombre " =1 si es hombre"

**** Ejercicio 1, inciso b ***

*Para no repetir la sintaxis en cada comando, armamos una muestra que tengan en cuenta a los individuos a los cuales vamos a analizar.
sum wage [w=pondiio],detail
local p95=r(p95)
gen muestra=1 if edad>=18 & edad<=54 & wage>0 & wage<=`p95' & wage!=.

*Construimos la variable de población
egen pob=sum(pondiio), by(aglomera)
gen pobm=pob/1000000
label var pobm " Población total (en millones) de cada aglomerado"

*Finalmente, evaluamos la existencia de diferencias salariales por ciudad
tabstat wage if muestra==1 [w=pondiio], s(mean sd cv min p50 max n) by(aglomera) f(%9.2f)

**** Ejercicio 1 inciso 3****
gen lwage=ln(wage)
label var lwage " logaritmo del salario horario"

*Elevamos la edad al cuadrado
gen edad2=edad^2
label var edad2 "Edad al cuadrado"

*Definimos el nivel educativo de las personas
gen prii = 1 if nivel == 1 | nivel==7
replace prii = 0 if prii !=1 & nivel != .
label var prii "=1 si primaria incompleta"

gen pric = 1 if nivel == 2 
replace pric = 0 if pric !=1 & nivel != .
label var pric "=1 si primaria completa"

gen seci = 1 if nivel == 3
replace seci = 0 if seci !=1 & nivel != .
label var seci "=1 si secundaria incompleta"

gen secc = 1 if nivel == 4 
replace secc = 0 if secc !=1 & nivel != .
label var secc "=1 si secundaria completa"

gen supi = 1 if nivel == 5
replace supi = 0 if supi !=1 & nivel != .
label var supi "=1 si superior incompleta"

gen supc = 1 if nivel == 6
replace supc = 0 if supc !=1 & nivel != .
label var supc "=1 si superior completa"

reg lwage pobm hombre edad edad2 prii pric seci secc supi supc [w=pondiio] if muestra==1, robust
*ssc install outreg
*ssc install outreg2
*outreg2 using "EJ1-inc3.xls", replace

**** Ejercicio 2 ***
clear 
use "TP1_ciudades.dta"

local paises="arg bra chl"


foreach pais of local paises {
preserve
keep if pais=="`pais'"

*Generamos el logaritmo de la población
gen pobm=pob/100000
gen lpobm=ln(pobm)

*Ahora, generamos el ranking de menor a mayor, siendo CABA=1, Córdoba=2 y así sucesivamente
gsort -pobm //de mayor a menor

*Una vez generado el ranking, lo construimos y le aplicamos logaritmo
gen rank=_n
gen lrank=ln(rank)

*Realizamos la regresión
regress lrank lpobm, robust

*Finalmente testeamos si alpha es igual a 1.
test lpobm=-1

*Gráfico de distribución observada
sort pobm
*graph twoway line rank pobm, name(total, replace)
*graph export distribucion_total_`pais'.png, replace

*graph twoway line rank pobm if rank<20, name(top20, replace) scheme(slcolor)
*graph export distribucion_top20_`pais'.png, replace

summarize pobm
return list
local A=r(max)
display `A'

gen pob_rsr=`A'/rank

sort pobm
*graph twoway (line rank pobm if rank<=20) (line rank pob_rsr if rank<=20), name(compara_dist, replace) title("Distribución de las ciudades") legend(row(1) label(1 "Observada") ///
*label (2 "Rank size rule")) ytitle("Ranking") xtitle("población")
*graph export distribución_ciu_`pais'.png, replace


restore
}

*** Ejercicio 2, inciso b ****

gen pobm=pob/100000
gen rank=_n
*Gráfico de distribución observada
sort pobm
graph twoway line rank pobm, name(total, replace)

graph twoway line rank pobm if rank<20, name(top20, replace)
