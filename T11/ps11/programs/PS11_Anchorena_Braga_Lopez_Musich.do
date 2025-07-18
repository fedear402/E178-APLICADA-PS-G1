/*******************************************************************************
PS 11: Matching
Universidad de San Andrés
Economía Aplicada
 
Integrantes: 
Ignacio Anchorena
Rodrigo Braga
Federico Ariel Lopez
Joaquin Musich
*******************************************************************************/
clear all
global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T11/ps11"
global output "$main/output"
global input "$main/input"

use "$input/base_censo", clear
********************************************************************************
* 1)
label var pobl_1999 "población"
label var via1 "principal vía de acceso" 
label var ranking_pobr "pobreza"

local vars pobl_1999 via1 ranking_pobr
estpost ttest `vars', by(treated)
esttab . using "$output/1.rtf", replace cells("b se t p") label title("Diferencia de medias")

eststo clear

********************************************************************************
* 2)
probit treated ind_abs_pobr ldens_pob prov_cap pob_1 pob_2 pob_3 pob_4 km_cap_prov via3 via5 via7 via9 region_2 region_3 laltitud tdesnutr deficit_post deficit_aulas
predict p_score


********************************************************************************
* 3)
twoway (kdensity p_score if treated==1,lwidth(thick) lpattern(solid) lcolor(black)) ///
 (kdensity p_score if treated==0, lwidth(thick) lpattern("_####_####") lcolor(black)), /// 
 scheme(s1mono) legend(lab(1 "Treated") lab(2 "Not treated")) xtitle("Propensity Score") ytitle("Density") 
graph export  "$output/3.png", replace


********************************************************************************
* 4)
bysort treated: summ p_score
egen x = min(p_score) if treated==1
egen psmin = min(x)
egen y = max(p_score) if treated==0
egen psmax=max(y)
drop x y
gen common_sup=1 if (p_score>=psmin & p_score<=psmax) & p_score!=.
replace common_sup=0 if common_sup==.

********************************************************************************
* 5)
psmatch2 treated if common_sup==1, p(p_score) noreplacement
gen matches=_weight
replace matches=0 if matches==.

********************************************************************************
* 6)
twoway (kdensity p_score if (treated==1 & matches==1),lwidth(thick) lpattern(solid) lcolor(black)) ///
 (kdensity p_score if (treated==0 & matches==1), lwidth(thick) lpattern("_####_####") lcolor(black)), /// 
 scheme(s1mono) legend(lab(1 "Treated") lab(2 "Not treated")) xtitle("Propensity Score") ytitle("Density") 
graph export  "$output/6.png", replace

********************************************************************************
* 7)
local vars pobl_1999 via1 ranking_pobr 
estpost ttest `vars' if matches == 1, by(treated)
esttab . using "$output/7.rtf", replace cells("b se t p") label title("Diferencia de medias matched")

eststo clear
