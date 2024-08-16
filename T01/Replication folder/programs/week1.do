/*******************************************************************************
                      Semana 1: Primeros pasos en Stata 

                          Universidad de San Andrés
                              Economía Aplicada
									2024							           
*******************************************************************************/

/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment

1) Cleaning data

2) Descriptive statistics

3) Figures

4) Regressions
*******************************************************************************/

/* Instructions: change global main in line 38 to run the code and reproduce all
   the results. */

   
* 0) Set up environment
*==============================================================================*
clear all // me aseguro de no pisar nada que tenga abierto

* Set working directory
cd "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/T01/Replication folder"
* Load dataset 
use "input/beauty", clear // Hamermesh, D. S., & Biddle, J. (1993). Beauty and the labor market.
 
* Save path in local or global
global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/T01/Replication folder"
global input "$main/input"
global output "$main/output"

use "$input/beauty.dta", clear
*==============================================================================*




* 1) Cleaning data
*==============================================================================*
* Visualizing data
browse

* Order dataset
order female married educ // order columns
sort wage // sort rows (from lower to higher wage)
gsort -wage // sort rows (from higher to lower wage)

* Check missings
*ssc install mdesc // help mdesc
mdesc // check missings in all variables
mdesc wage married // check missings in two particular variables

* Check particular values
count if wage== 0
count if wage==. // alternative way of checking missing values

* Keeping/dropping observations (same with variables)
keep if wage!=0
drop if wage==0

* Drop a variable
generate x=.
drop x

* Drop outliers
summarize wage, detail
drop if wage>r(p99) // borra datos por encima del percentil 99

****** Generate dummies
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



* 2) Descriptive statistics
*==============================================================================*
use "$input/beauty_clean", clear
* Summarize
*------------------------------------------------------------------------------*
summarize wage educ exper // displays obs, mean, SD, min, and max 

/* Loops:
 Suppose you want to summarize wages for each category of "looks". In this case, 
 you will use a for loop. Let's see the categories of 'looks' */

tab looks

* We loop through each value (1 to 5)
forval k = 1(1)5{
	summarize wage if looks == `k'
}

* Alternatively, using the bysort command
bysort look: sum wage

* Or you may want to repeat a process for different variables
foreach var of varlist black female sout expersq{
	summ `var'
}

* Imagine you want to create a new data set that contains the share of female, the median wage, and the number of unionized people, by "looks". We use collapse:
preserve   // This line saves the current data set in the memory
**# Bookmark #2
collapse (mean) female (median) wage (count) union, by(looks)
restore  // Go back to the saved data set 


* Export summarize (http://repec.org/bocode/e/estout/estpost.html#estpost101)
estpost summarize wage educ exper, listwise
esttab using "$output/tables/Table 1.tex", cells("mean sd min max") ///
nomtitle nonumber replace

* Adding labels
label var wage "Hourly wage in USD"
label var educ "Years of education"
label var exper "Years of experience"

* Again, but with labels
estpost summarize wage educ exper, listwise
esttab using "$output/tables/Table 2.tex", cells("mean sd min max") ///
nomtitle nonumber replace label 

* Customizing col names
estpost summarize wage educ exper, listwise
esttab using "$output/tables/Table 3.tex", cells("mean sd min max") ///
collabels("Mean" "SD" "Min" "Max") nomtitle nonumber replace label 

* Exporting to csv
estpost summarize wage educ exper, listwise
esttab using "$output/tables/Table 4.csv", cells("mean sd min max") ///
collabels("Mean" "SD" "Min" "Max") nomtitle nonumber replace label 

* Exporting to Word
estpost summarize wage educ exper, listwise
esttab using "$output/tables/Table 5.rtf", cells("mean sd min max") ///
collabels("Mean" "SD" "Min" "Max") nomtitle nonumber replace label 
*------------------------------------------------------------------------------*

* Tabstat
*------------------------------------------------------------------------------*
tabstat wage educ exper, stats(mean p50 range min max)
tabstat wage educ exper, stats(mean p50 range min max) by(female)

* Exporting results
estpost tabstat wage educ exper, listwise /// 
stats(mean p50 range min max)
esttab using "$output/tables/Table 6.rtf", cells("wage educ exper") ///
label replace

* Variables in rows instead of columns
estpost tabstat wage educ exper, listwise /// 
stats(mean p50 min max) columns(statistics)
esttab using "$output/tables/Table 7.rtf", cells("mean median min max") ///
label replace

* Adding column names
estpost tabstat wage educ exper, listwise /// 
stats(mean p50 min max) columns(statistics)
esttab using "$output/tables/Table 8.rtf", cells("mean p50 min max") ///
label replace collabels("Mean" "Median" "Min" "Max")

* Format of numbers
estpost tabstat wage educ exper, listwise /// 
stats(mean p50 min max) columns(statistics)
esttab using "$output/tables/Table 9.rtf", cells("mean(fmt(2)) p50(fmt(2)) min(fmt(2)) max(fmt(2))") ///
label replace collabels("Mean" "Median" "Min" "Max")
*------------------------------------------------------------------------------*
*==============================================================================*



* 3) Figures
*==============================================================================*

* Basic config
*ssc install grstyle
grstyle init // http://repec.sowi.unibe.ch/stata/grstyle/getting-started.html
grstyle set horizontal
grstyle color background white 
grstyle color heading black // Title in black

grstyle clear


* Histograms
*------------------------------------------------------------------------------*
* I want to see the distribution of "wage"
histogram wage, color(black%90) lcolor(gray) title("Distribution of wage")
graph export "$output/figures/wage_histogram.png", replace

* Compare the distribution of wage across genders
twoway (kdensity wage if female==1)   ///
       (kdensity wage if female==0), ///
legend(order(1 "Women" 2 "Men" )) title("Distribution of wage") ///
ytitle("Density") xtitle("Wage")
graph export "$output/figures/wage_histogram_menvswomen.png", replace
*------------------------------------------------------------------------------*

* Boxplot
*------------------------------------------------------------------------------*
* Compare the distribution of wage across genders
graph box wage, over(female)
graph box wage, over(female) nooutsides  // Remove outside obs
graph box wage, over(female, relabel(1 "Female" 2 "Male")) nooutsides  // Add labels
graph box wage, over(female, relabel(1 "Female" 2 "Male")) nooutsides note("") // Remove note
graph export "$output/figures/wage_boxplot_menvswomen.png", replace
*------------------------------------------------------------------------------*

* Scatter plots
*------------------------------------------------------------------------------*
* Relationship between wage and experience
scatter wage wage_parent
scatter wage wage_parent, msize(tiny) // change size of dots
label var wage_parent "Wage of parents" // add label
scatter wage wage_parent, msize(tiny) 
* Add fit line 
graph twoway (scatter wage wage_parent, msize(tiny)) (lfit wage wage_parent)
graph twoway (scatter wage wage_parent, msize(tiny)) (lfit wage wage_parent), legend(off) ytitle("Wage")
graph export "$output/figures/scatter_wage_wageparent.png", replace
* Compare male vs female
graph twoway (scatter wage wage_parent if female==0, mcolor(dknavy%50) msize(tiny)) (lfit wage wage_parent if female==0, lcolor(dknavy)) ///
             (scatter wage wage_parent if female==1, mcolor(dkgreen%50) msize(tiny)) (lfit wage wage_parent if female==1, lcolor(dkgreen)) ///
			 ,ytitle("Wage") legend(order(1 "Female" 3 "Male"))
graph export "$output/figures/scatter_wage_malevsfemale.png", replace
*------------------------------------------------------------------------------*
*==============================================================================*



* 4) Regressions
*==============================================================================*
* Relationship between beauty and income
regress wage looks
* Looks is categorical
regress wage plain average good_loking handsome // omit homely

* Relationship between beauty and income (including controls)
regress wage plain average good_loking handsome black married exper educ

* Outreg
*------------------------------------------------------------------------------*
ssc install outreg2
regress wage plain average good_loking handsome black married exper educ
outreg2 using "$output/tables/Table 10.rtf", replace 
* Add labels
label var plain "Plain"
label var average "Average"
label var good_loking "Good looking"
label var handsome "Handsome"
label var black "Black"
label var married "Married"

outreg2 using "$output/tables/Table 11.doc", replace label

* More than one regression in same table
regress wage plain average good_loking handsome // Reg 1: no controls
outreg2 using "$output/tables/Table 12.rtf", replace label
regress wage plain average good_loking handsome black married exper educ // Reg 2: controls
outreg2 using "$output/tables/Table 12.rtf", append label
regress wage plain average good_loking handsome black married exper educ south goodhlth bigcity smllcity // Reg 3: more controls
outreg2 using "$output/tables/Table 12.rtf", append label
*------------------------------------------------------------------------------*

* Esttab (http://repec.org/bocode/e/estout/esttab.html)
*------------------------------------------------------------------------------*
eststo clear
eststo: reg wage plain average good_loking handsome // Reg 1: no controls
eststo: reg wage plain average good_loking handsome black married exper educ // Reg 2: controls
eststo: reg wage plain average good_loking handsome black married exper educ south goodhlth bigcity smllcity // Reg 3: more controls
esttab , se r2 starlevels(* 0.10 ** 0.05 *** 0.01) 

esttab using "$output/tables/Table 13.rtf", replace label 


* Tabla con más detalles
eststo clear
eststo: reg wage plain average good_loking handsome // Reg 1: no controls
eststo: reg wage plain average good_loking handsome black married exper educ // Reg 2: controls
eststo: reg wage plain average good_loking handsome black married exper educ south goodhlth bigcity smllcity // Reg 3: more controls

esttab using "$output/tables/Table 14.rtf", se replace label noobs ///
keep(plain average good_loking handsome, relax) ///
stats(N r2, fmt(0 3) labels("Number of Observations" "R-Squared")) ///
addnotes("Specification 2 controls for race, married, experience and education. Specification 3 additionally controls for region and health.")

*------------------------------------------------------------------------------*
*==============================================================================*










