clear all
cd "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/rodri"  

import delimited using "shoplifting2.csv", delimiters(";") clear
rename ïestado estado
rename aão año
encode estado, gen(state)
gen fecha = ym(año, mes)
xtset state fecha


*ssc install synth

gen rgdpp = rgdp/population

synth rateper100000people unemploymentrate rgdpp poverty rgdpgrowth population rateper100000people(`=tm(2021m1)'(3)`=tm(2023m12)'), trunit(5) trperiod(`=tm(2023m12)') 


mat list e(W_weights)
* En e(X_balance) se guarda la matriz con las medias de los predictores para el sintético y el verdadero
mat list e(X_balance)
* me guardo la serie sintetica
mat list e(Y_synthetic)
mat Y_synth = e(Y_synthetic)
mata: Y_synth = st_matrix("Y_synth")
gen Y_synth_valores = .


forval m = 732/767 {
    mata: st_numscalar("value", Y_synth[`=`m'-731', 1])
    replace Y_synth_valores =  scalar(value) if fecha == `m'
}

format fecha %tm
twoway ///
(line rateper100000people fecha if state == 5, lwidth(thick) lcolor(black)) /// 
(line Y_synth_valores fecha if state == 5, lpattern(dash)) ///
, ytitle("Rates") xtitle("Year") ///
ylabel(0(10)50) yscale(r(0 50)) ///
legend(label(1 "California") label(2 "Synthetic")  /// 
position(4) ring(0) cols(1) textwidth(35) symxsize(4)) xline(767, lpattern(dash) lcolor(gray)) name("synth")

*****************************************************************
* Leave one out 

import delimited using "shoplifting2.csv", delimiters(";") clear
rename ïestado estado
rename aão año
encode estado, gen(state)
gen rgdpp = rgdp/population
gen fecha = ym(año, mes)
format fecha %tm
xtset state fecha

tempname resmat
        local i 5
        format fecha %tm
        qui synth rateper100000people unemploymentrate poverty rgdpp rgdpgrowth population rateper100000people(`=tm(2021m1)'(3)`=tm(2023m12)'), trunit(`i') trperiod(`=tm(2023m12)') xperiod(`=tm(2021m1)'(1)`=tm(2023m12)') keep(loo-resout`i', replace) 
                forvalues j=1/50 {
                    if `j'==5 { 
                        continue
                    }
					import delimited using "shoplifting2.csv", delimiters(";") clear
					rename ïestado estado
					rename aão año
					gen rgdpp = rgdp/population
					encode estado, gen(state)
					gen fecha = ym(año, mes)
					format fecha %tm
					xtset state fecha
                    * Remove a state based on encoded variable
                    drop if state==`j'
                    * Run synthetic control with updated data
                    format fecha %tm
                    qui synth rateper100000people unemploymentrate poverty population rgdpp rgdpgrowth rateper100000people(`=tm(2021m1)'(3)`=tm(2023m12)'), trunit(`i') trperiod(`=tm(2023m12)') xperiod(`=tm(2021m1)'(1)`=tm(2023m12)') keep(loo-resout`j', replace) 
                }
                
* volvemos a mergear las bases individuales
forvalues i = 1/50 {
use "loo-resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "loo-resout`i'.dta", replace
}
use "loo-resout1.dta", clear
forvalues i = 2/50 {
merge 1:1 _Co_Number _time using "loo-resout`i'.dta", nogen
}
format _time %tm
twoway (line _Y_synthetic_1 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_2 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_3 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_4 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_6 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_7 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_8 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_9 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_10 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_11 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_12 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_13 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_14 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_15 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_16 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_17 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_18 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_19 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_20 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_21 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_22 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_23 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_24 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_25 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_26 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_27 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_28 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_29 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_30 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_31 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_32 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_33 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_34 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_35 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_36 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_37 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_38 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_39 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_40 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_41 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_42 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_43 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_44 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_45 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_46 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_47 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_48 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_49 _time, lcolor(gray) lwidth(thin) lpattern(solid)) ///
		(line _Y_synthetic_50 _time, lcolor(gray) lwidth(thin) lpattern(solid) legend(label(49 "leave one outs") ) ) ///
		(line _Y_synthetic_5 _time, lcolor(black) lwidth(thin) lpattern(dash) legend(label(50 "Synthetic California") ) ) ///
        (line _Y_treated_5 _time, lcolor(black) lwidth(thick) lpattern(solid) legend(label(51 "California") ) ), ///
        ytitle("Rates") xtitle("fecha") ylabel(0(10)50) yscale(r(0 50)) ///
        legend(order(49 50 51) position(4) ring(0) cols(1) textwidth(30) symxsize(5) ) name("loop")



********************************************************************************
* fig 4

import delimited using "shoplifting2.csv", delimiters(";") clear
rename ïestado estado
rename aão año
encode estado, gen(state)
gen fecha = ym(año, mes)
xtset state fecha

synth rateper100000people unemploymentrate rgdpp poverty rgdpgrowth population rateper100000people(`=tm(2021m1)'(3)`=tm(2023m12)'), trunit(5) trperiod(`=tm(2023m06)') nested

mat list e(W_weights)
* En e(X_balance) se guarda la matriz con las medias de los predictores para el sintético y el verdadero
mat list e(X_balance)
* me guardo la serie sintetica
mat list e(Y_synthetic)
mat Y_synth = e(Y_synthetic)
mata: Y_synth = st_matrix("Y_synth")
gen Y_synth_valores = .

forval m = 732/767 {
    mata: st_numscalar("value", Y_synth[`=`m'-731', 1])
    replace Y_synth_valores = scalar(value) if fecha == `m'
}

format fecha %tm
twoway ///
(line rateper100000people fecha if state == 5, lwidth(thick) lcolor(black)) /// 
(line Y_synth_valores fecha if state == 5, lpattern(dash)), ///
ytitle("Rates") xtitle("Year") ///
ylabel(0(10)50) yscale(r(0 50)) ///
legend(label(1 "California") label(2 "Synthetic")  /// 
position(4) ring(0) cols(1) textwidth(35) symxsize(4)) xline(761, lpattern(dash) lcolor(gray)) name("intime")