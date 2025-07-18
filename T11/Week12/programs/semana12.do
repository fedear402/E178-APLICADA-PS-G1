/*******************************************************************************
                             Semana 12: Matching

                          Universidad de San Andrés
                              Economía Aplicada
							       2024							           
*******************************************************************************/


/* We have a model in which the individuals are high school students that receive 
a plan which consists on the provision of school supplies. We would like to evaluate 
the impact of this plan on the student performance in a standardized math test 
(named in our database as the variable “score”). The plan intends to be random but 
because of different implementation problems the assignment is not random. 
Our data is generated in a way that we know that the effect of the treatment on the treated is exactly 5. */


* 0) Set up environment
*==============================================================================*
clear all

global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T11/Week12"
global output "$main/output"
global input "$main/input"

use "$input/psm", clear
sort student
*==============================================================================*
 

* OLS estimates 
reg score treated female income hhsize divorced violence, robust


* Matching
*==============================================================================*
* Before calculating the propensity score we should drop all the observations with missing values. 
foreach var of varlist _all { 
drop if `var'==.
}

* Calculate propensity score
probit treated female income hhsize divorced violence
predict p_score

* Install pscore
search pscore

*** ATTND: nearest neighbor matching ***
attnd score treated, pscore(p_score) boot

*** ATT: stratification matching ***
pscore treated female income hhsize divorced violence, pscore(p_score) blockid(block)
* We observe that the balancing property is satisfied.
* What happens when the balancing condition is not satisfied?
pscore treated female income hhsize divorced violence, pscore(p_score1) blockid(block1) level(0.1)

atts score treated, pscore(p_score) blockid(block) boot

*** ATTR: radius matching ***
attr score treated, pscore(p_score) 

*** ATTK: kernel-based matching ***
attk score treated, pscore(p_score) boot

*** Common support ***
twoway (kdensity p_score if treated==1,lwidth(thick) lpattern(solid) lcolor(black)) ///
(kdensity p_score if treated==0, lwidth(thick) lpattern("_####_####") lcolor(black)) ///
, scheme(s1mono) legend(lab(1 "Treated") lab(2 "Not treated")) ///
xtitle("Propensity Score") ytitle("Density") 

bysort treated: summ p_score
egen x = min(p_score) if treated==1
egen psmin = min(x)
egen y = max(p_score) if treated==0
egen psmax=max(y)
drop x y
gen common_sup=1 if (p_score>=psmin & p_score<=psmax) & p_score!=.
replace common_sup=0 if common_sup==.
* We can also combine common support with other methods:
atts score treated, pscore(p_score) blockid(block) comsup

*==============================================================================*
