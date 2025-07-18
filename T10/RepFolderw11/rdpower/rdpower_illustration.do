********************************************************************************
** RDPOWER Stata Package 
** Do-file for Empirical Illustration
** Authors: Matias D. Cattaneo and Gonzalo Vazquez-Bare
** Last update: 12-Jun-2016
********************************************************************************
** hlp2winpdf, cdn(rdpower) replace
********************************************************************************
clear all
set more off
set linesize 90
capture log close

**************************************************************************
** Change to working directory
**************************************************************************

**************************************************************************
** Summary Stats
**************************************************************************
use rdpower_senate.dta, clear
global covariates presdemvoteshlag1 population demvoteshlag1 ///
                  demvoteshlag2 demwinprv1 demwinprv2 dopen dmidterm
describe $covariates
summarize demmv $covariates

gen T = demmv>=0
ttest demvoteshfor2, by(T)

**************************************************************************
** rdpower
**************************************************************************
rdpower demvoteshfor2 demmv

rdpower demvoteshfor2 demmv, plot
