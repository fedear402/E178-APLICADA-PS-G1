/*******************************************************************************
                        PS 8 : Control sintético
                       Universidad de San Andrés
                           Economía Aplicada
*******************************************************************************/
global main  
global output "$main/output"
global input "$main/input"
cd "$main"

import delimited using "$main/input/df.csv", clear
encode state, gen(state_n)
xtset state_n year

egen promedio_bra = mean(homiciderate) if state_n != 26, by(year)

* fig 1
twoway (line homiciderate year if state_n == 26) ///
       (line promedio_bra year if state_n == 1), ///
       ytitle("Homicide Rates") xtitle("Year")
graph export "$output/fig1.png", replace

synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(26) trperiod(1998) nested fig

mat list e(Y_synthetic)
mat Y_synth = e(Y_synthetic)
gen Y_synth_valores = .
forvalues y = 1990/2009 {
    local temp = Y_synth[`y' - 1989, 1]
    replace Y_synth_valores = `temp' if year == `y'
}

* fig 2
twoway (line homiciderate year if state_n == 26) (line Y_synth_valores year if state_n == 26), ///
       ytitle("Homicide Rates") xtitle("Year")
graph export "$output/fig2.png", replace

* fig 3
gen gaps = .
replace gaps = (homiciderate - Y_synth_valores) if state_n == 26
twoway (line gaps year if state_n == 26), ///
       ytitle("Gaps in Homicide Rates") xtitle("Year")
graph export "$output/fig3.png", replace

* fig 4
import delimited using "$main/input/df.csv", clear
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
twoway (line homiciderate year if state_n == 26) (line Y_synth_valores year if state_n == 26), ///
       ytitle("Homicide Rates") xtitle("Year")
graph export "$output/fig4.png", replace

* fig 5 
import delimited using "$main/input/df.csv", clear
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
    encode state, gen(state_n)
    xtset state_n year
    drop if state_n==`j'
    qui synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(26) trperiod(1998) xperiod(1990(1)2009) keep(loo-resout`j', replace)        
}
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
twoway (line _Y_synthetic_7 _time) (line _Y_synthetic_23 _time) (line _Y_synthetic_24 _time) ///
       (line _Y_treated_26 _time) (line _Y_synthetic_26 _time), ///
       ytitle("Homicide Rates") xtitle("Year")
graph export "$output/fig5.png", replace

* fig 6 
clear all
import delimited using "$main/input/df.csv", clear
encode state, gen(state_n)
xtset state_n year
tempname resmat
local i 26
qui synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(`i') trperiod(1998) xperiod(1990(1)2009) keep(resout`i', replace)
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
    local names `"`names' `"`i'"'"'
}
mat colnames `resmat' = "RMSPE"
mat rownames `resmat' = `names'
matlist `resmat' , row("Treated Unit")
use "resout3.dta", clear
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
twoway (line _Y_gap_1 _time) (line _Y_gap_2 _time) (line _Y_gap_3 _time) (line _Y_gap_4 _time) ///
       (line _Y_gap_5 _time) (line _Y_gap_6 _time) (line _Y_gap_7 _time) ///
       (line _Y_gap_26 _time), ytitle("Gap in Homicide Rates") xtitle("Year")
graph export "$output/fig6.png", replace

* fig 7 
clear all
import delimited using "$main/input/df.csv", clear
encode state, gen(state_n)
xtset state_n year
tempname resmat
local i 26
qui synth homiciderates stategdpcapita stategdpgrowthpercent populationprojectionln yearsschoolingimp giniimp proportionextremepoverty, trunit(`i') trperiod(1998) xperiod(1990(1)2009) keep(resout`i', replace)
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
    local names `"`names' `"`i'"'"'
}
mat colnames `resmat' = "RMSPE"
mat rownames `resmat' = `names'
matlist `resmat' , row("Treated Unit")
use "resout3.dta", clear
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
twoway (line _Y_gap_5 _time) (line _Y_gap_6 _time) (line _Y_gap_9 _time) (line _Y_gap_10 _time) ///
       (line _Y_gap_14 _time) (line _Y_gap_16 _time) (line _Y_gap_19 _time) ///
       (line _Y_gap_26 _time), ytitle("Gap in Homicide Rates") xtitle("Year")
graph export "$output/fig7.png", replace