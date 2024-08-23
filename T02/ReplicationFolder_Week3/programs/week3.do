/*******************************************************************************
                    Semana 3: Multiple Hypothesis Testing 

                          Universidad de San Andrés
                              Economía Aplicada
							       2024							           
*******************************************************************************/


/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment

1) Table 4 - Replication

2) Bonferroni Correction

3) Holm (1979)'s correction

4) Benjamini, Krieger, and Yekutieli (2006)s' correction
*******************************************************************************/

	
* 0) Set up environment
*==============================================================================*
clear all
set more off
* Change global main to reproduce results
global main "G:\Mi unidad\Clases\Tutoriales Aplicada 2024\Clases\3. Inferencia - MHT\Stata\Tutorial"
global input "$main/input"
global output "$main/output"
use "$input/UCT_FINAL_CLEAN.dta", clear
/* Haushofer, J., & Shapiro, J. (2016). The short-term impact of unconditional cash transfers to the poor: experimental evidence from Kenya. The Quarterly Journal of Economics, 131(4), 1973-2042. */
drop if purecontrol == 1

label var psy_lncort_mean1 "Log cortisol (no controls)"        
label var psy_lncort_mean_clean1 "Log cortisol (with controls)"
label var psy_cesdscore1 "Depression (CESD)"
label var psy_worries_z1 "Worries"
label var psy_stressscore_z1 "Stress (Cohen)" 
label var psy_hap_z1 "Happiness (WVS)"
label var psy_sat_z1 "Life satisfaction (WVS)"
label var psy_trust_z1 "Trust (WVS)"
label var psy_locus_z1 "Locus of control"
label var psy_scheierscore_z1 "Optimism (Scheier)"
label var psy_rosenbergscore_z1 "Self-esteem (Rosenberg)"
label var psy_index_z1 "Psychological well-being index"
*==============================================================================*


* 1) Table 4 - Replication
*==============================================================================*
* Row 1
eststo clear
eststo: reg psy_lncort_mean1 treat psy_lncort_mean_full0 psy_lncort_mean_miss0 i.village, cluster(surveyid)
esttab using "$output/Table 4 - Row 1.rtf", se replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(2) star) se(par fmt(2))) ///
stats(N r2, fmt(0 2) labels("Number of Observations" "R-Squared")) 

* Row 2
eststo clear
eststo: reg psy_lncort_mean_clean1 treat psy_lncort_mean_clean_full0 psy_lncort_mean_clean_miss0 i.village, cluster(surveyid)
esttab using "$output/Table 4 - Row 2.rtf", se replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(2) star) se(par fmt(2))) ///
stats(N r2, fmt(0 2) labels("Number of Observations" "R-Squared")) 

* All rows
global psyvars "psy_lncort_mean psy_lncort_mean_clean psy_cesdscore psy_worries_z psy_stressscore_z psy_hap_z psy_sat_z psy_trust_z psy_locus_z psy_scheierscore_z psy_rosenbergscore_z psy_index_z"
eststo clear
foreach y in $psyvars{
	local outcome "`y'1"
	eststo: reg `outcome' treat `y'_full0 `y'_miss0 i.village, cluster(surveyid)
}
esttab using "$output/Table 4.txt", se replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(2) star) se(par fmt(2))) ///
stats(N r2, fmt(0 2) labels("Number of Observations" "R-Squared")) 
*==============================================================================*



* 2) Bonferroni Correction
*==============================================================================*

* Remove index from list of variables
global psyvars "psy_lncort_mean psy_lncort_mean_clean psy_cesdscore psy_worries_z psy_stressscore_z psy_hap_z psy_sat_z psy_trust_z psy_locus_z psy_scheierscore_z psy_rosenbergscore_z"

* Store in a scalar the number of hypothesis tested
scalar hyp = 11

* Run regressions storing p-value
eststo clear
foreach y in $psyvars{
	local outcome "`y'1"
	reg `outcome' treat `y'_full0 `y'_miss0 i.village, cluster(surveyid)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
}
esttab using "$output/Table 4.txt", p se replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(2) star) se(par fmt(2))) ///
stats(p_value blank N r2, fmt(2 0 2) labels("P-value" " "  "Number of Observations" "R-Squared")) 

* Add corrected p-value
eststo clear
foreach y in $psyvars{
	local outcome "`y'1"
	reg `outcome' treat `y'_full0 `y'_miss0 i.village, cluster(surveyid)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
}
esttab using "$output/Table 4_bonferroni.txt", p se replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(2) star) se(par fmt(2))) ///
stats(p_value corr_p_value blank N r2, fmt(2 2 0 2) labels("P-value" "Corrected p-value" " "  "Number of Observations" "R-Squared")) 
*==============================================================================*


* 3) Holm Correction
*==============================================================================*
* Define number of hypothesis
scalar hyp = 11
* Define level of significance
scalar signif = 0.05

* Store p-values in matrix
scalar i = 1
mat p_values = J(11,1,.)
foreach y in $psyvars{
	local outcome "`y'1"
	reg `outcome' treat `y'_full0 `y'_miss0 i.village, cluster(surveyid)
	eststo: test treat = 0
	mat p_values[i,1]=r(p)
scalar i = i + 1
}

preserve
clear 
svmat p_values
gen var = _n
sort p_values1

gen alpha_corr = signif/(hyp+1-_n)

gen significant = (p_values1<alpha_corr)

replace significant = 0 if significant[_n-1]==0

sort var
restore
*==============================================================================*



* 4) Benjamini, Krieger, and Yekutieli (2006)s' correction
*==============================================================================*
* First, run regressions and keep p-values
preserve
scalar i = 1
mat p_values = J(11,1,.)
foreach y in $psyvars{
	local outcome "`y'1"
	reg `outcome' treat `y'_full0 `y'_miss0 i.village, cluster(surveyid)
	eststo: test treat = 0
	mat p_values[i,1]=r(p)
scalar i = i + 1
}
clear 
svmat p_values
gen outcome = _n
rename p_values1 pval
save "$output/pvals.dta", replace
restore

**** Now use Michael Anderson's code for sharpened q-values
preserve

use "$output/pvals.dta", clear
version 10
set more off

* Collect the total number of p-values tested
quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 
local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values
gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
	

quietly sort original_sorting_order
pause off
set more on

display "Code has completed."
display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
display	"Sorting order is the same as the original vector of p-values"

keep outcome pval bky06_qval
save "$output/sharpenedqvals.dta", replace

restore


* Finally, run regressions including p-value and corrected p-value
mat q_values_t = [0.788, 0.788, 0.014, 0.014, 0.001, 0.005, 0.002, 0.413, 0.445, 0.069, 0.788]

* Finally, run regressions including p-value and corrected p-value
scalar i = 1
eststo clear
foreach y in $psyvars{
	local outcome "`y'1"
	reg `outcome' treat `y'_full0 `y'_miss0 i.village, cluster(surveyid)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar p_value_corr = q_values_t[1,i]
scalar i = i+1
}
esttab using "$output/Table 4.rtf", p se replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(2) star) se(par fmt(2))) ///
stats(p_value p_value_corr blank N r2, fmt(2 2 0 2) labels("P-value" "Corrected p-value" " "  "Number of Observations" "R-Squared") layout([@] [@] @ @ @)) 
*==============================================================================*
