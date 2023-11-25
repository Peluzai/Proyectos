clear all
cd "C:\Users\maart\Desktop\Nicolas\Econometria\Proyecto Final"

use "arg_eph_19s1"
*Variables
*Regiones 1=Gran Buensaires,43==PAMPEANA 44==PATAGONIA 40==NOA, 41==NEA, 42=CUYO, 
gen lsalario=ln(p21)

gen horas = .
replace horas = pp3e_tot
replace horas = . if pp3e_tot>150

keep if region==1 | region==43

tab region
generate GBA=.
replace GBA= 1 if region==1
replace GBA=0 if region==43

generate Pampeana=.
replace Pampeana=1 if region==43
replace Pampeana=0 if region==1

gen casado=0
replace casado= 1 if ch07==1 | ch07==2

gen soltero=0
replace soltero= 1 if ch07==3 | ch07==4 | ch07==5

gen informal = . 
replace informal  = 1  if (pp07h == 2 & cat_ocup == 3) | (cat_ocup == 2 & nivel_ed<=5)
replace informal  = 0  if (pp07h == 1 & cat_ocup == 3) | (cat_ocup == 2 & nivel_ed==6)
gen formal = .
replace formal = 1 if (pp07h == 1 & cat_ocup == 3) | (cat_ocup == 2 & nivel_ed==6)
replace formal  = 0  if (pp07h == 2 & cat_ocup == 3) | (cat_ocup == 2 & nivel_ed<=5)

gen Multi = .
replace Multi = GBA*formal

gen edad = .
replace edad = ch06

gen edad2 = .
replace edad2 = edad^2

gen hombre=.
replace hombre = 1 if ch04==1
replace hombre = 0 if ch04==2


*probar con i.region, con todas las regiones

regress lsalario GBA formal i.nivel_ed casado Multi edad edad2 horas hombre

*table GBA informal, c(mean) row col
















