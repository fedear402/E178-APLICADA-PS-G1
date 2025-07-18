/*******************************************************************************
PS 10: Regression Discontinuity
Universidad de San Andrés
Economía Aplicada

Integrantes: 
Ignacio Anchorena
Rodrigo Braga
Federico Ariel Lopez
Joaquin Musich
*******************************************************************************/
 
global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T10/PS_week11"
global output "$main/output"
global input "$main/input"
cd "$main"
use "$input/Grades5", clear

*********** EJ A **************
reg avgmath classize
est store math

reg avgverb classize
est store verb

esttab math verb using "$output/a.rtf", replace label alignment(center) compress modelwidth(20)  mtitles("Average Math Score" "Average Lang Score") nonumber

eststo clear


************EJ B **************
reg avgmath classize tip_a enroll
est store math

reg avgverb classize tip_a enroll
est store verb


esttab math verb using "$output/b.rtf", replace label alignment(center) compress modelwidth(20)  mtitles("Average Math Score" "Average Lang Score") nonumber
eststo clear


*********** EJ D ************************************************
global covs "tip_a"
global x enroll

*** Density discontinuity test
*** placebo tests on pre-determined covariates


********* EJ E ************************************************

// Primero lo hacemos con matematica

* RD plot 

*Polinomio grado 1
rdplot avgmath $x, c(40) p(1) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota matematica) name(gavgmathp1, replace)) 
                            
*Polinomio grado 2
rdplot avgmath $x, c(40) p(2) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota matematica) name(gavgmathp2, replace)) 

*Polinomio grado 3
                            
rdplot avgmath $x, c(40) p(3) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota matematica) name(gavgmathp3, replace)) 
                            
*Polinomio grado 4

rdplot avgmath $x, c(40) p(4) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota matematica) name(gavgmathp4, replace)) 
    
***** Ahora veo los coeficientes con polinomio grado i
    

rdrobust avgmath $x, c(40) p(1) masspoints(off) stdvars(on) 

* with covariates
rdrobust avgmath $x, c(40) p(1) covs($covs) masspoints(off) stdvars(on)
    
rdrobust avgmath $x, c(40) p(2) masspoints(off) stdvars(on) 

* with covariates
rdrobust avgmath $x, c(40) p(2) covs($covs) masspoints(off) stdvars(on)
        
rdrobust avgmath $x, c(40) p(3) masspoints(off) stdvars(on) 

* with covariates
rdrobust avgmath $x, c(40) p(3) covs($covs) masspoints(off) stdvars(on)

rdrobust avgmath $x, c(40) p(4) masspoints(off) stdvars(on) 

* with covariates
rdrobust avgmath $x, c(40) p(4) covs($covs) masspoints(off) stdvars(on)
    
    
    
// Ahora repito lo mismo para Lengua

rdplot avgverb $x, c(40) p(1) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota Lengua) name(gavgverbp1, replace)) 
                            
*Polinomio grado 2
rdplot avgverb $x, c(40) p(2) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota Lengua) name(gavgverbp2, replace)) 
*Polinomio grado 3
                            
rdplot avgverb $x, c(40) p(3) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota Lengua) name(gavgverbp3, replace)) 
                            
*Polinomio grado 4

rdplot avgverb $x, c(40) p(4) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota Lengua) name(gavgverbp4, replace)) 

                            
                            
                            
******** Ej F ***********
global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T10/PS_week11"
global output "$main/output"
global input "$main/input"
cd "$main"
use "$input/Grades5", clear
eststo clear
global x enroll
global y_avgmath avgmath
global y_avgverb avgverb
global covs "tip_a"
global ys "avgmath avgverb"
foreach y of global ys {
	local yl = "`y'"
	foreach band in 10 15 7 {
		eststo: rdrobust `yl' $x, c(40) covs($covs) masspoints(off) stdvars(on) p(1) h(`band')
		estadd local bandwidth = `band'
		estadd local cutoff = "40"
		estadd local N_left = e(N_h_l)
		estadd local N_right = e(N_h_r)
		estadd local order_polynomial = e(p)
	}
}
esttab using "$output/f.rtf", se replace label noobs stats(cutoff bandwidth N_left N_right order_polynomial controls, fmt(0 4 0 0 0)) collabels("Cut-off" "Bandwidth" "Left" "Right)" "P")

// Bandwith=10

rdplot avgmath $x, c(40) p(1) h(10) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota matematica) name(gavgmathp1h10, replace)) 
                            
rdplot avgverb $x, c(40) p(1) h(10) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota Lengua) name(gavgverbp1h10, replace))       
                            
// Bandwith=15

rdplot avgmath $x, c(40) p(1) h(15) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota matematica) name(gavgmathp1h15, replace)) 
                            
rdplot avgverb $x, c(40) p(1) h(15) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota Lengua) name(gavgverbp1h15, replace))       
                            
// Bandwith=7

rdplot avgmath $x, c(40) p(1) h(7) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota matematica) name(gavgmathp1h7, replace)) 
                            
                            
                            
rdplot avgverb $x, c(40) p(1) h(7) graph_options(graphregion(color(white)) ///
                            xtitle(enroll) ///
                            ytitle(Nota Lengua) name(gavgverbp1h7, replace)) 
							
							

							
							
*********** EJ g ****************
global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T10/PS_week11"
global output "$main/output"
global input "$main/input"
cd "$main" 
use "$input/Grades5", clear
eststo clear

gen zs = enroll / (floor((enroll - 1) / 40) + 1)
global ys "avgmath avgverb" 
foreach y of global ys {
	local outcome_var = "`y'"
	ivregress 2sls `y' (classize = zs) tip_a, robust
	eststo: ivregress 2sls `y' (classize = zs) tip_a, robust
}

esttab using "$output/g.rtf", se replace label 
                            
