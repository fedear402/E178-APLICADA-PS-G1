/*******************************************************************************
                       Semana 11: Regression discontinuity
                          Universidad de San Andrés
                              Economía Aplicada
							       2024							           
*******************************************************************************/

global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T10/RepFolderw11"
global output "$main/output"
global input "$main/input"
cd "$output"

********************************************************************************
** The Regression Discontinuity Design -- Re-analysis of Klasnja Titiunik (2017)
** Authors: Matias D. Cattaneo, Rocio Titiunik and Gonzalo Vazquez-Bare
** Last update: 21-AGO-2020
********************************************************************************

** SOFTWARE WEBSITE: https://rdpackages.github.io/
********************************************************************************

********************************************************************************
* Score:   mv_incparty (margin of victory of incumbent party at t)
* Outcome: indicator for victory of incumbent party at t+1 
* Cutoff:  0
********************************************************************************
** NOTE: If you are using RDROBUST version 2020 or newer, the option 
** "masspoints(off) stdvars(on)" may be needed to replicate the results in the 
** paper. For example, line 79:
**
**     rdrobust $y $x
**
** should be replaced by:
**
**     rdrobust $y $x, masspoints(off) stdvars(on)
********************************************************************************
** NOTE: If you are using RDDENSITY version 2020 or newer, the option 
** "nomasspoints" may be needed to replicate the results in the 
** paper. For example, line 55:
**
**     rddensity $x, plot
**
** should be replaced by:
**
**     rddensity $x, nomasspoints plot
********************************************************************************

********************************************************************************
** Load Data
********************************************************************************

use "$input/CTV_2020_Sage.dta", clear
global y mv_incpartyfor1 
* y is margin of victory at t + 1  
global x mv_incparty
* x is margin of victory at t 

global covs "pibpc population numpar_candidates_eff party_DEM_wonlag1_b1 party_PSDB_wonlag1_b1 party_PT_wonlag1_b1 party_PMDB_wonlag1_b1"
* there are seven covariates at the municipality level: per-capita GDP, population, number of effective parties, and indicators for whether each of four parties (the Democratas, PSDB, PT and PMDB) won the prior (t − 1) election.

********************************************************************************
** Falsification analysis
********************************************************************************

* x is margin of victory at t 
* y is margin of victory at t + 1  

*** Density discontinuity test
rddensity $x

* Placebo tests on pre-determined covariates
foreach var of global covs {
	rdrobust `var' $x
	qui rdplot `var' $x if abs($x)<=30, graph_options(graphregion(color(white)) ///
													  xlabel(-30(10)30) ///
													  ytitle(`var') name(g`var', replace)) 
}

********************************************************************************
* Outcome analysis 
********************************************************************************

* RD plot 
rdplot $y $x, graph_options(graphregion(color(white)) ///
							xtitle(Margin of Victory at t) ///
							ytitle(Margin of Victory at t+1) name(g$y, replace)) 

* Continuity based approach  
* Reminder: Continuity-based approach : RD como diferencia de ordenadas 
rdrobust $y $x, masspoints(off) stdvars(on) 

* with covariates
rdrobust $y $x, covs($covs) masspoints(off) stdvars(on)

** ADDED: use old rd command
* ssc install rd
rd $y $x

* Local randomization approach : RD as difference of means 

* Window selector: uncomment to run. Can take a long time.
* rdwinselect $x $covs, wmin(0.05) wstep(0.01) nwindows(200) seed(765) plot graph_options(xtitle(Half window length) ytitle(Minimum p-value across all covariates) graphregion(color(white)) name(windows, replace))

/*We must choose the window around the cutoff where the assumption of local randomization
appears plausible (if such a window exists). We implement our window selection procedure
using the list of covariates mentioned above, an increment of 0.01 percentage points, and a
cutoff p-value of 0.15. We use Fisherian randomization-based inference with the difference in-
means as the test statistic and assuming a fixed-margins randomization procedure using
the actual number of treated and controls in each window. Starting
at the [0:05;-0:05] window and considering all symmetric windows in 0.01 increments, we
see that all windows between [0:05;-0:05] and [0:15;-0:15] have a minimum p-value above
0.15. The window [0:08;-0:08] is the first window where the minimum p-value drops below
0.15, indeed, it drops all the way to 0.061. Thus, our selected window is [-0:15; 0:15], which
has exactly 38 observations on each side of the cutoff.*/

rdwinselect $x $covs, wmin(0.05) wstep(0.01) nwindows(20) seed(765) plot graph_options(xtitle(Half window length) ytitle(Minimum p-value across all covariates) graphregion(color(white)))

* Randomization inference
local  w =  0.15
rdrandinf $y $x, wl(-`w') wr(`w') reps(1000) seed(765)

