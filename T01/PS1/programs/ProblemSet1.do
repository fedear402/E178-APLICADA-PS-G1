/*******************************************************************************
								Problem Set 1 

                          Universidad de San Andrés
                              Economía Aplicada
									2024							           
*******************************************************************************/

* ENVIRONMENT
*==============================================================================*
clear all 
 
* Save path in local or global
global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/T01/PS1"
global input "$main/input"
global output "$main/output"

use "$input/data_russia.dta", clear
*==============================================================================*


* DATA
*==============================================================================*

foreach var of varlist id site inwgt sex econrk powrnk resprk satlif satecc highsc belief monage obese cmedin hprblm hosl3m htself wtchng evalhl operat hattac smokes alclmo height waistc hipsiz hhpres totexpr tincm_r geo work0 work1 work2 ortho marsta1 marsta2 marsta3 marsta4 {
	su `var'
	tab `var'
}

// OK : marsta1 marsta2 marsta3 marsta4 height htself inwgt site
// corregir : 
/* 
	- pasar texto a numero (eg 'one' -> 1) + destring
		geo hattac operat evalhl wtchng operat satlif resprk powrnk econrk
	- binaria en texto 
		smokes obese sex
		
	- binaria como string sin missings
		ortho work0 work1 work2 operat hprblm
	- binaria como string con missings
		hhpres alclmo hattac hhpres hosl3m cmedin highsc
		
	- tab para hacer varias binarias
		geo
	- continua como string
		tincm_r waistc monage belief satecc

	- continua con prefijo string
		totexpr hipsiz 
*/
*********************** problemas:



// texto a numero (eg 'one' -> 1)
foreach var of varlist geo hattac operat evalhl wtchng operat satlif resprk powrnk econrk{
	replace `var' = "1" if `var' == "one"
	replace `var' = "2" if `var' == "two"
	replace `var' = "3" if `var' == "three"
	replace `var' = "4" if `var' == "four"
	replace `var' = "5" if `var' == "five"
	replace `var' = "6" if `var' == "six"
	replace `var' = "7" if `var' == "seven"
	replace `var' = "8" if `var' == "eight"
	replace `var' = "9" if `var' == "nine"
	replace `var' = "10" if `var' == "ten"
}

// binaria con texto : 		smokes obese sex
replace smokes="1" if smokes == "Smokes"
replace sex="1" if sex == "male"
replace sex="0" if sex == "female"
replace obese="1" if  obese == "This person is obese"
replace obese="0" if  obese == "This person is not obese"
replace hipsiz = substr(hipsiz, 18, .)
replace totexpr = substr(totexpr, 19, .)


// destring
foreach var of varlist geo hattac operat evalhl wtchng satlif resprk powrnk econrk ortho work0 work1 work2 hprblm hhpres alclmo hosl3m cmedin highsc sex tincm_r waistc monage belief satecc hipsiz obese smokes totexpr marsta1 marsta2 marsta3 marsta4{
	destring `var', gen(`var'_) dpcomma
	drop `var'
	rename `var'_ `var' 
}


destring geo, gen(geo_)
drop geo
rename geo_ geo

***** missings
mdesc
//self-reported height (htself) tiene 185 (6.5%) de missings y height tiene 28 (1%)

*********************** renombrar:
rename marsta4 widowed_m4
rename marsta3 divorced_m3
rename marsta2 livetog_m2
rename marsta1 married_m1

***********************

* Check particular values
count if inwgt== 0
count if wage==. // alternative way of checking missing values

* Keeping/dropping observations (same with variables)
keep if wage!=0
drop if wage==0

* Drop a variable
generate x=.
drop x

* Drop outliers
summarize wage, detail
drop if wage>r(p99)

* Generate dummies
* 1. High and low income
summarize wage, d // return list to see stored values
gen high_income = .
replace high_income = 1 if wage>r(p50)
replace high_income = 0 if wage<=r(p50)
tabulate high_income // shows values of variable
* Label variables
label var high_income "Income above median"
* Alternatively
cap drop high_income // drop returns "error" if variable doesn't exists
summarize wage, detail
gen high_income = (wage>r(p50))

* 2. Beauty dummies
tab looks, gen(beauty)
rename beauty1 homely
rename beauty2 plain 
rename beauty3 average
rename beauty4 good_loking
rename beauty5 handsome    


* Save database (with a different name!!!)
save "$input/beauty_clean", replace
*==============================================================================*
