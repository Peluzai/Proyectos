clear all
cd "C:\Users\Escorpio\Desktop\Pelusa\Facultad\5to\2ndo Cuatrimestre\Salud"

import excel using "base_usuario_encoprac2022.xlsx", firstrow

* Recodifica la variable de consumo de alcohol
gen ConsumoRegular = (AL_05 == 4)

* Recodifica la variable de actividad física
gen ActFisica = SA_06
replace ActFisica = 0 if SA_06 == 5  // Recodifica 'No realiza regularmente actividades físicas' a 0

* Realiza una regresión logística
logit ConsumoRegular ActFisica

* Crea una tabla de contingencia
tabulate ActFisica AL_05

* Recodificación de las nuevas variables
gen LugarConsumo = AL_16
gen CompaniaConsumo = AL_17
gen FumoTabacoh30Dias = TA_08

* Recodificación de LugarConsumo para reducir categorías (puedes ajustar según tus necesidades)
recode LugarConsumo (1=1 "En su casa") (2=2 "En casa de amigos/as o pareja") (3=3 "En lugar público") ///
                     (4=4 "En evento público") (5=5 "En boliche, bar o restaurante") ///
                     (6=6 "En una fiesta") (7=7 "En el trabajo") (8=8 "Otro lugar o situación"), ///
                     gen(LugarConsumoRecod)

* Realiza la regresión logística incluyendo las nuevas variables
logit ConsumoRegular ActFisica LugarConsumoRecod CompaniaConsumo FumoTabacoh30Dias

* Crear una variable que indique si la persona fuma por cada motivo
gen FumaPorMotivo = TA_13__1 | TA_13__2 | TA_13__3 | TA_13__4 | TA_13__5 | TA_13__6 | TA_13__7 | TA_13__8 | TA_13__9 | TA_13__10

* Tabla de frecuencia para cada motivo
tab FumaPorMotivo, matcell(FumaPorMotivo_mat)

* Mostrar la tabla de frecuencias en la ventana de resultados
matrix list FumaPorMotivo_mat

* Crear variables para cada motivo específico
gen FumaPorPlacerCuriosidad = TA_13__1
gen FumaParaRelajarse = TA_13__2
gen FumaParaDesinhibirse = TA_13__3
gen FumaParaEnfrentarRealidad = TA_13__4
gen FumaParaEstimularseEstarAlerta = TA_13__5
gen FumaPorPresionGrupalSocial = TA_13__6
gen FumaPorCostumbreHabito = TA_13__7
gen FumaPorSoledadAbandono = TA_13__8
gen FumaPorOtrosMotivos = TA_13__9
gen FumaEnSituacionesSociales = TA_13__10

* Crear una variable que indique si la persona fuma por al menos un motivo
gen FumaPorAlMenosUnMotivo = FumaPorPlacerCuriosidad | FumaParaRelajarse | FumaParaDesinhibirse | FumaParaEnfrentarRealidad | FumaParaEstimularseEstarAlerta | FumaPorPresionGrupalSocial | FumaPorCostumbreHabito | FumaPorSoledadAbandono | FumaPorOtrosMotivos | FumaEnSituacionesSociales

* Crear una tabla de frecuencia para la variable combinada
tab FumaPorAlMenosUnMotivo, matcell(FumaPorAlMenosUnMotivo_mat)

* Mostrar la tabla de frecuencias en la ventana de resultados
matrix list FumaPorAlMenosUnMotivo_mat

* Crear una tabla de frecuencia para cada motivo
foreach motivo in FumaPorPlacerCuriosidad FumaParaRelajarse FumaParaDesinhibirse FumaParaEnfrentarRealidad FumaParaEstimularseEstarAlerta FumaPorPresionGrupalSocial FumaPorCostumbreHabito FumaPorSoledadAbandono FumaPorOtrosMotivos FumaEnSituacionesSociales {
    tab `motivo', matcell(FumaMotivo_mat)
    matrix list FumaMotivo_mat
}

* Crear un gráfico de barras agrupadas
graph bar FumaPorPlacerCuriosidad FumaParaRelajarse FumaParaDesinhibirse FumaParaEnfrentarRealidad FumaParaEstimularseEstarAlerta FumaPorPresionGrupalSocial FumaPorCostumbreHabito FumaPorSoledadAbandono FumaPorOtrosMotivos FumaEnSituacionesSociales, ///
  over(FumaPorAlMenosUnMotivo) ///
  title("Motivos para Fumar en los Últimos 30 Días") ///
  ylabel(0 "No" 1 "Sí") ///
  legend(on)

  * Filtrar las observaciones que cumplen con la condición TR_03 != 998 & TR_03 != 999
keep if TR_03 != 998 & TR_03 != 999

sum P1M_TA
tab TA_17
sum TA_17
tab PV_TA
tab P1A_TA
tab P1M_TA

* Filtrar las observaciones que cumplen con la condición TR_03 != 998 & TR_03 != 999
keep if TR_03 != 998 & TR_03 != 999

* Calcular la edad promedio en la que las personas tomaron tranquilizantes por primera vez
sum TR_03

tab TR_07

tabulate TA_01 AL_05
