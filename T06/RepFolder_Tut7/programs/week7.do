/*******************************************************************************
                          Semana 7: Diff-in-Diff

                          Universidad de San Andrés
                              Economía Aplicada
							        2024							           
*******************************************************************************/

 
/*******************************************************************************
This file has the following structure:

0) Set up environment

1) DiD

2) Goodman-Bacon (2019)

3) Callaway & Sant'Anna (2020)

4) Borusyak et al.(2021)

*******************************************************************************/


* 0) Set up environment
*==============================================================================*

global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T06/RepFolder_Tut7"
global output "$main/output"
global input "$main/input"
cd "$output"


* 1) DiD
*==============================================================================*

*use http://pped.org/bacon_example.dta, clear
use "$input/stevenson_wolfers", clear
* https://users.nber.org/~jwolfers/Papers/bargaining_in_the_shadow_of_the_law.pdf

* Generate variable eventually treated
bys stfips: egen eventually=max(_nfd)
replace eventually=1 if eventually!=.
recode eventually (.=0)

* Check if there are never treated (if there are no obs in eventually=0, all the states are eventually treated)
tab eventually 

* Check years when states start to be treated
tab _nfd

* Basic Graph (pre treatment by year)
bysort Año eventually: egen mean=mean(y)
twoway (connected mean Año if even==1 & year<1969) (connected mean year if even==0 & year<1969, lpattern(longdash)), ytitle(Mean Outcome)  xtitle (Year) legend(order(1 "Eventually treated" 2 "Controls")) scheme(sj)

*5)	The problem we face is that since if treatment was imposed in different years, we have very few periods in which no states were treated to compare. Therefore, what we can do is determine the line in the year where most observations were treated. We erase the observations of the ones treated before 1973, so the before 1973 graph is "clean of treatment" and we have more pre-treatment periods.
drop mean
drop if post==1 & (year<1973)
bysort year even: egen mean=mean(asmrs)

twoway (connected mean year if even==1 & year<1973) (connected mean year if even==0 & year<1973, lpattern(longdash)), ytitle(Mean Outcome)  xtitle (Year) legend(order(1 "Eventually treated" 2 "Controls")) scheme(sj)

* The problem is that we have few observations...
tab mean year if year <1971
  
* ** Event Study Graph (Stata Command)

*ssc install eventdd
*ssc install matsort
*ssc install boottest

local treat_id stfips
local time year
local treatment post
local outcome asmrs
local treatment_year _nfd

gen timeToTreat = `time' - `treatment_year'

save temp.dta, replace

eventdd `outcome' i.`time', timevar(timeToTreat) method(fe,cluster(`treat_id')) keepdummies graph_op(ytitle("Outcome") xlabel(-20(5)25))
 
* Test the joint significance for leads and lags (CAUTION! the leads are the negative ones and the lags the positive ones).	
estat eventdd

* Test the joint significance for leads and lags using wild bootstrap (importart because there are few observations in some of the dots.
estat eventdd, wboot seed(1234)

* You can choose the number of leads and lags, but you must specify what to do with the remaining ones: accumulate, in range or keep the ones that are balanced.

local treat_id stfips
local time year
local treatment post
local outcome asmrs
local treatment_year _nfd

eventdd `outcome' i.`time', timevar(timeToTreat) method(fe,cluster(`treat_id')) keepdummies graph_op(ytitle("Outcome") xlabel(-10(5)15)) leads(10) lags(15) accum


** Event Study Graph (by hand)

ssc install reghdfe    
ssc install ftools 
ssc install coefplot

use "$input/stevenson_wolfers", clear

local treat_id stfips
local time year
local treatment post
local outcome asmrs

bys `treat_id': egen ev_treat=max(`treatment')
bys `treat_id': gen tdate=`time' if `treatment'==1
bys `treat_id': egen treatdate=min(tdate)
gen window=`time'-treatdate if ev_treat==1
tab window, gen(dummy)
** CHOOSE j
local j = -22
forvalues i=1/`r(r)'{
replace dummy`i'=0 if ev_treat==0
local j = `j'+1
label var dummy`i' "`j'"
}

local treat_id stfips
local time year
local treatment post
local outcome asmrs
local treatment_year _nfd

reghdfe `outcome' dummy1-dummy20 dummy22-dummy54, absorb(`time' `treat_id') cluster(`treat_id')

coefplot , keep(dummy1 dummy2 dummy3 dummy4 dummy5 dummy6 dummy7 dummy8 dummy9 dummy10 dummy11 dummy12 dummy13 dummy14 dummy15 dummy16 dummy17 dummy18 dummy19 dummy20 dummy21 dummy22 dummy23 dummy24 dummy25 dummy26 dummy27 dummy28 dummy29 dummy30 dummy31 dummy32 dummy33 dummy34 dummy35 dummy36 dummy37 dummy38 dummy39 dummy40 dummy41 dummy42 dummy43 dummy44 dummy45 dummy46 dummy47 dummy48 dummy49 dummy50 dummy51 dummy52 dummy53 dummy54) vertical yline(0) ci(95) xtitle("Time since shock") ytitle("Coefficient") ciopts(recast(rcap)) baselevels omitted legend(off) name(g1, replace) xline(20.5) 

coefplot , keep(dummy12 dummy13 dummy14 dummy15 dummy16 dummy17 dummy18 dummy19 dummy20 dummy21 dummy22 dummy23 dummy24 dummy25 dummy26 dummy27 dummy28 dummy29 dummy30 dummy31 dummy32 dummy33 dummy34 dummy35 dummy36 dummy37 dummy38 dummy39 dummy40 dummy41 dummy42 dummy43 dummy44 dummy45 dummy46 dummy47 dummy48) vertical yline(0) ci(95) xtitle("Time since shock") ytitle("Coefficient") ciopts(recast(rcap)) baselevels omitted legend(off) name(g2, replace) xline(9.5)


** Difference-in-differences

xtreg asmrs post pcinc asmrh cases i.year, fe i(stfips) robust


* 2) Goodman-Bacon (2019)
*==============================================================================*

ssc install bacondecomp

use "$input/stevenson_wolfers", clear

** Bacon Decomposition
xtreg asmrs post i.year, fe robust

*Request the detailed decomposition of the DD model.
bacondecomp asmrs post , stub(Bacon_) ddetail


* 3) Callaway & Sant'Anna (2020)
*==============================================================================*

ssc install drdid
ssc install csdid

* Same data set as before 
use "$input/stevenson_wolfers", clear

* This command requires that the year of treatment variable has a zero if the unit was never treated.

replace _nfd = 0 if _nfd == .

* CS
csdid asmrs pcinc asmrh cases, ivar(stfips) time(year) gvar(_nfd) method(reg) notyet

* Pretrends test
estat pretrend

* Average ATT
estat simple

* ATT by year
estat calendar

* ATT by group
estat group

* Event study plot
estat event
csdid_plot

* Dynamic effects by groups
csdid asmrs pcinc asmrh cases, ivar(stfips) time(year) gvar(_nfd) method(reg) notyet 
csdid_plot, group(1969) name(m1,replace) title("Group 1969")
csdid_plot, group(1970) name(m2,replace) title("Group 1970")
csdid_plot, group(1971) name(m3,replace) title("Group 1971")
csdid_plot, group(1984) name(m4,replace) title("Group 1984")
graph combine m1 m2 m3 m4, xcommon scale(0.8)



* 3) Borusyak et al.(2021)
*==============================================================================*

ssc install did_imputation

/*
did_imputation Y i t Ei [if] [in] [estimation weights] [, options]
  Y       outcome variable
  i       variable for unique unit id
  t       variable for calendar period
  Ei      variable for unit-specific date of treatment (missing = never-treated)
*/

use "$input/stevenson_wolfers", clear


* "Baseline" specification 
did_imputation asmrs stfips year _nfd

* Including time-varying controls
did_imputation asmrs stfips year _nfd, controls(asmrh cases)

* Dynamic effects (6 periods ahead)
did_imputation asmrs stfips year _nfd, controls(asmrh cases) horizons(0/6) 

* Additionally report pre-trend coefficients for leads 1,...,5.
did_imputation asmrs stfips year _nfd, controls(asmrh cases) horizons(0/6) pretrends(5)


