/*******************************************************************************
PS 8 : Control sintético
Universidad de San Andrés
Economía Aplicada
Integrantes:  
        Ignacio Anchorena
        Rodrigo Braga
        Federico Ariel Lopez
        Joaquin Musich
*******************************************************************************/

global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T08/PS8"
global output "$main/output"
global input "$main/input"
cd "$main"

import delimited using "$main/input/df.csv", clear
replace state = "São Paulo" if state == "SÃ£o Paulo"
encode state, gen(state_n)
xtset state_n year

egen promedio_bra = mean(homiciderate) if state_n != 26, by(year)
********************************************************************************
* fig 1
twoway ///
(line homiciderate year if state_n == 26, lwidth(thick) lcolor(black)) /// 
(line promedio_bra year if state_n == 25, lpattern(dash)) ///
, ytitle("Homicide Rates") xtitle("Year") ///
ylabel(0(10)60) yscale(r(0 60)) ///
legend(label(1 "São Paulo") label(2 "Brazil (average)")  /// 
position(8) ring(0) cols(1) textwidth(23) symxsize(4)) ///
xline(1998, lpattern(dash) lcolor(gray))
graph export  "$output/fig1.png", replace

synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(26) trperiod(1998) nested fig

forvalues y = 1990/2009 { 
        disp `y' 
}
mat list e(W_weights)
* En e(X_balance) se guarda la matriz con las medias de los predictores para el sintético y el verdadero
mat list e(X_balance)
* me guardo la serie sintetica
mat list e(Y_synthetic)
mat Y_synth = e(Y_synthetic)
gen Y_synth_valores = .
forvalues y = 1990/2009 {
    local sdfsdf = Y_synth[`y' - 1989, 1]
    replace Y_synth_valores = `sdfsdf' if year == `y'
}

********************************************************************************
* fig 2
twoway ///
(line homiciderate year if state_n == 26, lwidth(thick) lcolor(black)) /// 
(line Y_synth_valores year if state_n == 26, lpattern(dash)) ///
, ytitle("Homicide Rates") xtitle("Year") ///
ylabel(10(10)60) yscale(r(10 60)) ///
legend(label(1 "São Paulo") label(2 "Synthetic São Paulo")  /// 
position(8) ring(0) cols(1) textwidth(35) symxsize(4)) ///
xline(1998, lpattern(dash) lcolor(gray))
graph export  "$output/fig2.png", replace


********************************************************************************
* fig 3
gen gaps = .
replace gaps = (homiciderate - Y_synth_valores) if state_n == 26

twoway ///
(line gaps year if state_n == 26, lwidth(thick) lcolor(black)) /// 
, ytitle("Gaps in Homicide Rates") xtitle("Year") ///
ylabel(-30(10)30) yscale(r(-30 30)) ///
xline(1998, lpattern(dash) lcolor(gray)) ///
yline(0, lpattern(dash) lcolor(black))
graph export  "$output/fig3.png", replace


********************************************************************************
* fig 4
import delimited using "$main/input/df.csv", clear
replace state = "São Paulo" if state == "SÃ£o Paulo"
encode state, gen(state_n)
drop if year > 1998
xtset state_n year

synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(26) trperiod(1995) nested fig

mat Y_synth = e(Y_synthetic)
gen Y_synth_valores = .
forvalues y = 1990/1998 {
    local sdfsdf = Y_synth[`y' - 1989, 1]
    replace Y_synth_valores = `sdfsdf' if year == `y'
}

twoway ///
(line homiciderate year if state_n == 26, lwidth(thick) lcolor(black)) /// 
(line Y_synth_valores year if state_n == 26, lpattern(dash)) ///
, ytitle("Homicide Rates") xtitle("Year") ///
ylabel(0(10)60) yscale(r(0 60)) ///
legend(label(1 "São Paulo") label(2 "Synthetic São Paulo")  /// 
position(8) ring(0) cols(1) textwidth(35) symxsize(4)) ///
xline(1995, lpattern(dash) lcolor(gray))
graph export  "$output/fig4.png", replace


********************************************************************************
* fig 5 : Leave one out 
import delimited using "$main/input/df.csv", clear
replace state = "São Paulo" if state == "SÃ£o Paulo"
encode state, gen(state_n)
xtset state_n year
tempname resmat
        local i 26
        qui synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(`i') trperiod(1998) xperiod(1990(1)2009) keep(loo-resout`i', replace)     
                
                forvalues j=1/27 {
                    if `j'==26 { 
                        continue
                    }
                    import delimited using "$main/input/df.csv", clear
                    replace state = "São Paulo" if state == "SÃ£o Paulo"
                    encode state, gen(state_n)
                    xtset state_n year
                    * Remove a state based on encoded variable
                    drop if state_n==`j'
                    * Run synthetic control with updated data
                    qui synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(26) trperiod(1998) xperiod(1990(1)2009) keep(loo-resout`j', replace)        
                }



                
* volvemos a mergear las bases individuales
forvalues i = 1/27 {
use "loo-resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "loo-resout`i'.dta", replace
}

use "loo-resout1.dta", clear
forvalues i = 2/27 {
merge 1:1 _Co_Number _time using "loo-resout`i'.dta", nogen
}

twoway (line _Y_synthetic_7 _time, lcolor(gray) lwidth(thin) ///
         lpattern(solid) legend(label(1 "Synthetic São Paulo (leave one out)")) ) ///
       (line _Y_synthetic_23 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_synthetic_24 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_treated_26 _time, lcolor(black) lpattern(solid) legend(label(4 "São Paulo") ) ) ///
       (line _Y_synthetic_26 _time, lcolor(black) lpattern(dash) legend(label(5 "Synthetic São Paulo")  lpattern(dash) ) ), /// 
        ytitle("Homicide Rates") xtitle("Year") ///
        ylabel(10(10)60) yscale(r(10 60)) /// 
        legend(order(4 5 1) position(8) ring(0) cols(1) textwidth(60) symxsize(5)) ///
        xline(1998, lpattern(dash) lcolor(gray))

graph export  "$output/fig5.png", replace



********************************************************************************
* fig 6 : placebos

clear all
import delimited using "$main/input/df.csv", clear
replace state = "São Paulo" if state == "SÃ£o Paulo"
encode state, gen(state_n)
xtset state_n year

tempname resmat
        local i 26
        qui synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(`i') trperiod(1998) xperiod(1990(1)2009) keep(resout`i', replace)     
                * Resout es una matriz que nos guarda para cada "year": outcome sintetico, outcome treated, y weights. 
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")
                drop if state_n == 26
                
        forvalues i = 1/27 {
                if `i'==26 { 
                continue
                }
        qui synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(`i') trperiod(1998) xperiod(1990(1)2009) keep(resout`i', replace)
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
                * Nos guardamos el MSPE
        local names `"`names' `"`i'"'"'
        }
                
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")

* fijemonos que contiene cada base resout`i'
use "resout3.dta", clear

* renombro variables de cada base individual para despues hacer un merge. 
forvalues i = 1/27 {
use "resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "resout`i'.dta", replace
}

use "resout1.dta", clear
forvalues i = 2/27 {
merge 1:1 _Co_Number _time using "resout`i'.dta", nogen
}

twoway (line _Y_gap_1 _time, lcolor(gray) lpattern(solid) /// 
        legend(label(1 "Control states")) ) ///
       (line _Y_gap_2 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_3 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_4 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_5 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_6 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_7 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_8 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_9 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_10 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_11 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_12 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_13 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_14 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_15 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_16 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_17 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_18 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_19 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_20 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_21 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_22 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_23 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_24 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_25 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_27 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_26 _time, lcolor(black) lwidth(thick) lpattern(solid) legend(label(27 "São Paulo") ) ), /// 
        ytitle("Gap in Homicide Rates") xtitle("Year") ///
        ylabel(-30(10)30) yscale(r(-30 30)) ///
        legend(order(27 1) position(8) ring(0) cols(1) textwidth(30) symxsize(5)) ///
        xline(1998, lpattern(dash) lcolor(gray)) ///
        yline(0, lpattern(solid) lcolor(black))
graph export  "$output/fig6.png", replace


********************************************************************************
* fig 7 : placebos (algunos)

clear all
import delimited using "$main/input/df.csv", clear
replace state = "São Paulo" if state == "SÃ£o Paulo"
encode state, gen(state_n)
xtset state_n year

tempname resmat
        local i 26
        qui synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(`i') trperiod(1998) xperiod(1990(1)2009) keep(resout`i', replace)     
                * Resout es una matriz que nos guarda para cada "year": outcome sintetico, outcome treated, y weights. 
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")
                drop if state_n == 26
                
        forvalues i = 1/27 {
                if `i'==26 { 
                continue
                }
        qui synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(`i') trperiod(1998) xperiod(1990(1)2009) keep(resout`i', replace)
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
                * Nos guardamos el MSPE
        local names `"`names' `"`i'"'"'
        }
                
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")

/*

Treated Unit |     RMSPE 
-------------+-----------
          26 |  3.261704 
           1 |  7.052483 
           2 |   17.6648 
           3 |  14.71914 
           4 |  13.66277 
           5 |  2.948762 -
           6 |  2.316661 -
           7 |  17.27511 
           8 |  16.86609 
           9 |  4.127187 -
          10 |  3.192369 -
          11 |  12.30525 
          12 |  9.435383 
          13 |  10.26978 
          14 |  2.431522 -
          15 |  13.18879 
          16 |  4.073998 -
          17 |  23.21934 
          18 |  15.30902 
          19 |  3.835551 -
          20 |  4.293679 -
          21 |  30.58504 
          22 |  12.30056 
          23 |  19.78524 
          24 |  13.47249 
          25 |  10.09636 
          27 |  7.649329 

*/
* RMSPE menores que 2x el de SP (<6.4):
* 5,6,9,10,14,16,19,20

* fijemonos que contiene cada base resout`i'
use "resout3.dta", clear

* renombro variables de cada base individual para despues hacer un merge. 
forvalues i = 1/27 {
use "resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "resout`i'.dta", replace
}

use "resout1.dta", clear
forvalues i = 2/27 {
merge 1:1 _Co_Number _time using "resout`i'.dta", nogen
}




twoway (line _Y_gap_5 _time, lcolor(gray) lpattern(solid) /// 
        legend(label(1 "Control states")) ) ///
       (line _Y_gap_6 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_9 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_10 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_14 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_16 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_19 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
       (line _Y_gap_20 _time, lcolor(gray) lwidth(thin) lpattern(solid)) /// 
       (line _Y_gap_26 _time, lcolor(black) lwidth(thick) lpattern(solid) legend(label(9 "São Paulo") ) ), /// 
        ytitle("Gap in Homicide Rates") xtitle("Year") ///
        ylabel(-30(10)30) yscale(r(-30 30)) ///
        legend(order(9 1) position(8) ring(0) cols(1) textwidth(30) symxsize(5)) ///
        xline(1998, lpattern(dash) lcolor(gray)) ///
        yline(0, lpattern(solid) lcolor(black))

graph export  "$output/fig7.png", replace
