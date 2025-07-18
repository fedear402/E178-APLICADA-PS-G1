/*******************************************************************************
			     Control sintético
                          Universidad de San Andrés
                              Economía Aplicada
*******************************************************************************/
/******************************************************************************* 
Este archivo sigue la siguiente estructura:

0) Set up environment

1) Abadie, Diamante, y Hainmueller (2010)

2) Ejemplo país vasco

*******************************************************************************/

* 0) Set up environment
*==============================================================================*

global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T08/week9synth"
global output "$main/outputs"
global input "$main/input"

cd "$main"

* 1) Abadie, Diamante, y Hainmueller (2010)
*==============================================================================*
	
/*
Este conjunto de datos panel contiene información para los 39 estados de los EEUU para los 
años 1970-2000 (ver Abadie, Diamante, y Hainmueller (2010) para más detalles). */

use "$input/smoking.dta", clear

* Aclarar a Stata que es un panel
tsset state year

* Instalar el comando
* ssc install synth

* Ejemplo 1.a
synth cigsale beer(1984(1)1988) lnincome retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975), trunit(3) trperiod(1989) nested fig

/* En este ejemplo, la unidad afectada por la intervención es la unidad número 3 (California) 
en el año 1989. 

Los "donors" son por defecto las unidades 1,2,4,5, ..., 39; es decir, los otros 38 estados del 
conjunto de datos. Si se desea especificar los donors se debe utilizar la opción counit ().  

Dado que no se especifíca xperiod (), las variables retprice, lnincome y age15to24 se promedian sobre el 
todo el periodo de pre-intervención hasta el año de la intervención (1970,1981, ..., 1988). 

La variable beer tiene el periodo de tiempo (1984 (1) 1988) especificado, lo que significa que es 
un promedio de los periodos 1984,1985, ..., 1988. 

La variable cigsale se utiliza tres veces como un predictor usando los valores de 
periodos 1988, 1980 y 1975 respectivamente. 

El MSPE se minimiza sobre todo el periodo de pretratamiento, porque mspeperiod () no se proporciona. 

Por defecto, los resultados son muestra para el período comprendido entre 1970,1971, ..., 2000 
(todo el periodo). 

Siempre usar NESTED: will lead to better performance, however, at the expense of additional computing time.

Alternativamente, el usuario puede también especificar la opción "allopt" para asignar una matriz V para iniciar la optimización que puede mejorar el ajuste incluso más (requiere aún más tiempo de cálculo). 

*/

* Los outputs de los comandos generalmente se guardan en matrices en la memoria de Stata. 

eret list

* En e(W_weights) se guardan los pesos de cada unidad

mat list e(W_weights)

* En e(X_balance) se guarda la matriz con las medias de los predictores para el sintético y el verdadero

mat list e(X_balance)

* Hay un comando muy útil para exportar matrices a tablas.

* ssc install frmtable 

* Lo uso para exportar las matrices (me quedo con dos deciales)

frmttable , statmat(e(W_weights)) sdec(0,2)

* Puede ser que no me interese la segunda columna

mat weights = e(W_weights)[1..38,2]

frmttable using "$output/state_weights.rtf", statmat(weights) sdec(2) ctitle("State", "Weight")

* Ahora exporto la matriz de balances
frmttable using "$output/variables_balance.rtf" , statmat(e(X_balance)) sdec(2,2) ctitle("Variable", "Treated", "Synthetic") rtitle("Beer consumption pc 1984-1998" \ "log(Income)" \ "Cigarette retail price" \ "% Pop age 15 to 24" \ "Cigarette sales in 1988" \ "Cigarette sales in 1980" \ "Cigarette sales in 1975")

* Ejemplo 1.b  

use "$input/smoking.dta", clear
tsset state year 

synth cigsale beer lnincome(1980&1985) retprice cigsale(1988) cigsale(1980) cigsale(1975), trunit(3) trperiod(1989) fig nested

/* Este ejemplo es similar al ejemplo 1.a, pero ahora beer se promedia sobre todo el 
periodo de pretratamiento mientras lnincome sólo se promedia entre los periodos 1980 y 1985.
Ya que no hay datos disponibles para beer antes de 1984, synth informará al usuario de que hay 
falta de datos para esta variable y que los valores que faltan son ignorados en el cálculo del 
promedio. */

* Ejemplo 1.c

use "$input/smoking.dta", clear
tsset state year 

synth cigsale beer lnincome retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975) , trunit(3) trperiod(1989) xperiod(1980(1)1988) nested keep(resout2) fig 

/* Se especifica laopción "xperiod()" lo que indica que los predictores se promedian para el 
periodo 1980,1981, ..., 1988. */

matrix gaps=e(Y_treated) -e(Y_synthetic)
matrix Y_treated=e(Y_treated)
matrix Y_synthetic=e(Y_synthetic)
keep year 
svmat gaps
svmat Y_treated
svmat Y_synthetic

twoway (line Y_treated1 year) (line Y_synthetic1 year) (scatter gaps1 year, yaxis(2)), legend(col(3)) xline(1989)
********************************************************************************
*A continuación se muestra un ejemplo para correr un placebo con todos los otros estados como tratados

use "$input/smoking.dta", clear
tsset state year 

tempname resmat
        local i 3
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975) , trunit(`i') trperiod(1989) xperiod(1980(1)1988) keep(resout`i', replace)	
		* Resout es una matriz que nos guarda para cada "year": outcome sintetico, outcome treated, y weights. 
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")
		
		drop if state==3
		
        forvalues i = 1/31 {
		if `i'==3 { 
		continue
		}
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975) , trunit(`i') trperiod(1989) xperiod(1980(1)1988) keep(resout`i', replace)	
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
		* Nos guardamos el MSPE
        local names `"`names' `"`i'"'"'
        }
		
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")

* fijemonos que contiene cada base resout`i'
use "$output/resout3.dta", clear

* renombro variables de cada base individual para despues hacer un merge. 
forvalues i = 1/31 {
use "$output/resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "$output/resout`i'.dta", replace
}

use "$output/resout1.dta", clear
forvalues i = 2/31 {
merge 1:1 _Co_Number _time using "$output/resout`i'.dta", nogen
}

*twoway (line _Y_synthetic_1 _time, lcolor(gray)) (line _Y_synthetic_2 _time, lcolor(gray)) (line _Y_treated_3 _time, lcolor(black) lwidth(thick)) (line _Y_synthetic_4 _time, lcolor(gray)) (line _Y_synthetic_5 _time, lcolor(gray)) (line _Y_synthetic_6 _time, lcolor(gray)) (line _Y_synthetic_7 _time, lcolor(gray)) (line _Y_synthetic_8 _time, lcolor(gray)) (line _Y_synthetic_9 _time, lcolor(gray)) (line _Y_synthetic_10 _time, lcolor(gray)) (line _Y_synthetic_11 _time, lcolor(gray)) (line _Y_synthetic_12 _time, lcolor(gray)) (line _Y_synthetic_13 _time, lcolor(gray)) (line _Y_synthetic_14 _time, lcolor(gray)) (line _Y_synthetic_15 _time, lcolor(gray)) (line _Y_synthetic_16 _time, lcolor(gray)) (line _Y_synthetic_17 _time, lcolor(gray)) (line _Y_synthetic_18 _time, lcolor(gray)) (line _Y_synthetic_19 _time, lcolor(gray)) (line _Y_synthetic_20 _time, lcolor(gray)) (line _Y_synthetic_21 _time, lcolor(gray)) (line _Y_synthetic_22 _time, lcolor(maroon)) (line _Y_synthetic_23 _time, lcolor(gray)) (line _Y_synthetic_24 _time, lcolor(gray)) (line _Y_synthetic_25 _time, lcolor(gray)) (line _Y_synthetic_26 _time, lcolor(gray)) (line _Y_synthetic_27 _time, lcolor(gray)) (line _Y_synthetic_28 _time, lcolor(gray)) (line _Y_synthetic_29 _time, lcolor(gray)) (line _Y_synthetic_30 _time, lcolor(gray)) (line _Y_synthetic_31 _time, lcolor(gray)), xline(1989) legend(off) name(gg1, replace)
	
twoway (line _Y_gap_1 _time, lcolor(gray)) (line _Y_gap_2 _time, lcolor(gray)) (line _Y_gap_4 _time, lcolor(gray)) (line _Y_gap_5 _time, lcolor(gray)) (line _Y_gap_6 _time, lcolor(gray)) (line _Y_gap_7 _time, lcolor(gray)) (line _Y_gap_8 _time, lcolor(gray)) (line _Y_gap_9 _time, lcolor(gray)) (line _Y_gap_10 _time, lcolor(gray)) (line _Y_gap_11 _time, lcolor(gray)) (line _Y_gap_12 _time, lcolor(gray)) (line _Y_gap_13 _time, lcolor(gray)) (line _Y_gap_14 _time, lcolor(gray)) (line _Y_gap_15 _time, lcolor(gray)) (line _Y_gap_16 _time, lcolor(gray)) (line _Y_gap_17 _time, lcolor(gray)) (line _Y_gap_18 _time, lcolor(gray)) (line _Y_gap_19 _time, lcolor(gray)) (line _Y_gap_20 _time, lcolor(gray)) (line _Y_gap_21 _time, lcolor(gray)) (line _Y_gap_22 _time, lcolor(maroon)) (line _Y_gap_23 _time, lcolor(gray)) (line _Y_gap_24 _time, lcolor(gray)) (line _Y_gap_25 _time, lcolor(gray)) (line _Y_gap_26 _time, lcolor(gray)) (line _Y_gap_27 _time, lcolor(gray)) (line _Y_gap_28 _time, lcolor(gray)) (line _Y_gap_29 _time, lcolor(gray)) (line _Y_gap_30 _time, lcolor(gray)) (line _Y_gap_31 _time, lcolor(gray)) (line _Y_gap_3 _time, lcolor(black) lwidth(thick)), xline(1989) legend(off) name(gg2,replace)

********************************************************************************
* Leave one out	
use "$input/smoking.dta", clear
tsset state year 

tempname resmat
        local i 3
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975) , trunit(`i') trperiod(1989) xperiod(1980(1)1988) keep(loo-resout`i', replace)	
		
		forvalues j=1/31 {
		if `j'==3 { 
		continue
		}
		use "$input/smoking.dta", clear
		tsset state year 
		* sacamos un estado
		drop if state==`j'
		* corremos el sintetico
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975), trunit(3) trperiod(1989) xperiod(1980(1)1988) keep(loo-resout`j', replace)	
        }
		
* volvemos a mergear las bases individuales
forvalues i = 1/31 {
use "$output/loo-resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "$output/loo-resout`i'.dta", replace
}

use "$output/loo-resout1.dta", clear
forvalues i = 2/31 {
merge 1:1 _Co_Number _time using "$output/loo-resout`i'.dta", nogen
}

twoway (line _Y_synthetic_1 _time, lcolor(gray)) (line _Y_synthetic_2 _time, lcolor(gray)) (line _Y_synthetic_4 _time, lcolor(gray)) (line _Y_synthetic_5 _time, lcolor(gray)) (line _Y_synthetic_6 _time, lcolor(gray)) (line _Y_synthetic_7 _time, lcolor(gray)) (line _Y_synthetic_8 _time, lcolor(gray)) (line _Y_synthetic_9 _time, lcolor(gray)) (line _Y_synthetic_10 _time, lcolor(gray)) (line _Y_synthetic_11 _time, lcolor(gray)) (line _Y_synthetic_12 _time, lcolor(gray)) (line _Y_synthetic_13 _time, lcolor(gray)) (line _Y_synthetic_14 _time, lcolor(gray)) (line _Y_synthetic_15 _time, lcolor(gray)) (line _Y_synthetic_16 _time, lcolor(gray)) (line _Y_synthetic_17 _time, lcolor(gray)) (line _Y_synthetic_18 _time, lcolor(gray)) (line _Y_synthetic_19 _time, lcolor(gray)) (line _Y_synthetic_20 _time, lcolor(gray)) (line _Y_synthetic_21 _time, lcolor(gray)) (line _Y_synthetic_22 _time, lcolor(gray)) (line _Y_synthetic_23 _time, lcolor(gray)) (line _Y_synthetic_24 _time, lcolor(gray)) (line _Y_synthetic_25 _time, lcolor(gray)) (line _Y_synthetic_26 _time, lcolor(gray)) (line _Y_synthetic_27 _time, lcolor(gray)) (line _Y_synthetic_28 _time, lcolor(gray)) (line _Y_synthetic_29 _time, lcolor(gray)) (line _Y_synthetic_30 _time, lcolor(gray)) (line _Y_synthetic_31 _time, lcolor(gray)) (line _Y_treated_3 _time, lcolor(black) lwidth(thick)) (line _Y_synthetic_3 _time, lcolor(black)), xline(1989) legend(off)
	
* same plot with gaps	
*twoway (line _Y_gap_1 _time, lcolor(gray)) (line _Y_gap_2 _time, lcolor(gray)) (line _Y_gap_4 _time, lcolor(gray)) (line _Y_gap_5 _time, lcolor(gray)) (line _Y_gap_6 _time, lcolor(gray)) (line _Y_gap_7 _time, lcolor(gray)) (line _Y_gap_8 _time, lcolor(gray)) (line _Y_gap_9 _time, lcolor(gray)) (line _Y_gap_10 _time, lcolor(gray)) (line _Y_gap_11 _time, lcolor(gray)) (line _Y_gap_12 _time, lcolor(gray)) (line _Y_gap_13 _time, lcolor(gray)) (line _Y_gap_14 _time, lcolor(gray)) (line _Y_gap_15 _time, lcolor(gray)) (line _Y_gap_16 _time, lcolor(gray)) (line _Y_gap_17 _time, lcolor(gray)) (line _Y_gap_18 _time, lcolor(gray)) (line _Y_gap_19 _time, lcolor(gray)) (line _Y_gap_20 _time, lcolor(gray)) (line _Y_gap_21 _time, lcolor(gray)) (line _Y_gap_22 _time, lcolor(maroon)) (line _Y_gap_23 _time, lcolor(gray)) (line _Y_gap_24 _time, lcolor(gray)) (line _Y_gap_25 _time, lcolor(gray)) (line _Y_gap_26 _time, lcolor(gray)) (line _Y_gap_27 _time, lcolor(gray)) (line _Y_gap_28 _time, lcolor(gray)) (line _Y_gap_29 _time, lcolor(gray)) (line _Y_gap_30 _time, lcolor(gray)) (line _Y_gap_31 _time, lcolor(gray)) (line _Y_gap_3 _time, lcolor(black) lwidth(thick)), xline(1989) legend(off)		

********************************************************************************
* In-time placebo	
tempname resmat
use "$input/smoking.dta", clear
tsset state year
        forvalues t = 1980/1989 {
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975) , trunit(3) trperiod(`t') keep(resout`t', replace)		
        }
		
forvalues t = 1980/1989 {
use "$output/resout`t'.dta", clear
ren _Y_synthetic _Y_synthetic_`t'
ren _Y_treated _Y_treated_`t'
gen _Y_gap_`t'=_Y_treated_`t'-_Y_synthetic_`t'
save "$output/resout`t'.dta", replace
}

use "$output/resout1980.dta", clear
forvalues t = 1981/1989 {
merge 1:1 _Co_Number _time using "$output/resout`t'.dta", nogen
}

* Remember, ideally, no impacts will be find in the pre treatment period
twoway (line _Y_gap_1981 _time , lcolor(gray) ) (line _Y_gap_1982 _time , lcolor(gray)) (line _Y_gap_1983 _time , lcolor(gray)) (line _Y_gap_1984 _time , lcolor(gray)) (line _Y_gap_1985 _time , lcolor(gray)) (line _Y_gap_1986 _time , lcolor(gray)) (line _Y_gap_1987 _time , lcolor(gray)) (line _Y_gap_1988 _time , lcolor(gray)) (line _Y_gap_1989 _time, lcolor(black) lwidth(thick)), legend(off) xline(1989)
		
twoway (line _Y_synthetic_1981 _time , lcolor(gray) ) (line _Y_synthetic_1982 _time , lcolor(gray)) (line _Y_synthetic_1983 _time , lcolor(gray)) (line _Y_synthetic_1984 _time , lcolor(gray)) (line _Y_synthetic_1985 _time , lcolor(gray)) (line _Y_synthetic_1986 _time , lcolor(gray)) (line _Y_synthetic_1987 _time , lcolor(gray)) (line _Y_synthetic_1988 _time , lcolor(gray)) (line _Y_treated_1989 _time, lcolor(black) lwidth(thick)), legend(off) xline(1989)


*==================================*
* Synthetic Difference in Differences
*==================================*

use "$input/smoking.dta", clear

* set panel and check that is strongly balanced
tsset state year 

* We need to generate treatment dummy 
gen treated = (state == 3 & year > 1988)

* ssc intall sdid

* webuse set www.damianclarke.net/stata/
* webuse prop99_example.dta, clear

/* Structure of code:

Y: Outcome variable (numeric)
S: Unit variable (numeric or string)
T: Time variable (numeric)
D: Dummy of treatement, equal to 1 if units are treated, and otherwise 0 (numeric)

sdid Y S T D [if] [in], vce(method) seed(#) reps(#) covariates(varlist [, method])
                        zeta_lambda(real) zeta_omega(real) min_dec(real) max_iter(real)
                        method(methodtype) unstandardized graph_export([stub] , type) mattitles
                        graph g1on g1_opt(string) g2_opt(string) msize() 
						
- vce(): bootstrap, jackknife and placebo. If you want to omit this procedure use noinference. If only one treated region, placebo is required.
- method(): sdid for Synthetic DiD, did for DiD and sc for Synthetic Control.
- seed(): seed define for pseudo-random numbers.
- reps(): repetitions for bootstrap and placebo se.
- covariates( varlist [, method]): covariates included to adjust Y. A varlist of covariates should be included, and optionally an option for the method used to adjust. This can be "optimized" in which case it follows the method proposed by Arkhangelsky et al., or "projected", in which case it follows the procedure proposed by Kranz, 2021 (xsynth in R). Where method is not specified, optimized is used as default. Kranz has shown that the projected method is preferable in a number of circumstances. In this implementation, the projected method is often considerably faster.

*/

#delimit ;
eststo sdid_1: sdid cigsale state year treated, vce(placebo) reps(100) seed(123) 
     graph g1on g1_opt(xtitle("") ylabel(-35(5)10) scheme(plotplainblind)) 
     g2_opt(ylabel(0(50)150) xlabel(1970(5)2000) ytitle("Packs per capita") 
            xtitle("") scheme(plotplainblind))
    graph_export(sdid_, .png);
#delimit cr

* Add covariates with covs(): no missing values allowed!
* if a covariate with missing values wants to be included, first drop missing values, then apply sdid

#delimit ;
eststo sdid_2: sdid cigsale state year treated, vce(placebo) reps(100) seed(123) covariates(retprice)
     graph g1on g1_opt(xtitle("") ylabel(-35(5)10) scheme(plotplainblind)) 
     g2_opt(ylabel(0(50)150) xlabel(1970(5)2000) ytitle("Packs per capita") 
            xtitle("") scheme(plotplainblind))
    graph_export(sdid_, .png);
#delimit cr

esttab sdid_1 sdid_2 , starlevel ("*" 0.10 "**" 0.05 "***" 0.01) b(%-9.3f) se(%-9.3f)

* If a covariate with missing values wants to be included, first drop missing values, then apply sdid. 
preserve
drop if lnincome==.
sdid cigsale state year treated, vce(placebo) reps(100) seed(123) covariates(lnincome retprice)
restore

*=============================* 
* SDID with STAGGERED ADOPTION
*=============================* 

* Advantages: is the exact same code structure!

/* Structure of code:

Y: Outcome variable (numeric)
S: Unit variable (numeric or string)
T: Time variable (numeric)
D: Dummy of treatement, equal to 1 if units are treated, and otherwise 0 (numeric)

sdid Y S T D [if] [in], vce(method) seed(#) reps(#) covariates(varlist [, method])
                        min_dec(real) max_iter(real) graph_export([stub] , type) mattitles
                        graph g1on g1_opt(string) g2_opt(string) msize() 
*/

webuse quota_example.dta, clear

sdid womparl country year quota, vce(bootstrap) seed(1234)
* we can use bootstrap SE, because we have more than one treated unit. 
* for placebo SE: sdid womparl country year quota, vce(placebo) seed(1234)

* same estimate with lngdp as control
preserve
drop if lngdp==.
sdid womparl country year quota, vce(bootstrap) seed(1234) covariates(lngdp)
restore


* EOF
