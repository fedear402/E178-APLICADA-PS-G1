/*******************************************************************************
                      Semana 8: Cluster robust inference

                          Universidad de San Andrés
                              Economía Aplicada
							        2024							           
*******************************************************************************/

* 0) Set up environment
*==============================================================================*
clear all

global main "/Users/tomaspacheco/Library/CloudStorage/GoogleDrive-tpacheco@udesa.edu.ar/Mi unidad/UdeSA/Aplicada2024/Clases/8. Robust Inference/Replication folder"
global output "$main/output"
global input "$main/input"
global programs "$main/programs"


/* Ref: Acemoglu, D., Cantoni, D., Johnson, S., & Robinson, J. A. (2011). 
The consequences of radical reform: The French Revolution. 
American economic review, 101(7), 3286-3307.*/

use "$input/20100816_replication_dataset.dta"

keep if year==1700 | year==1750 | year==1800 | year==1850 | year==1875 | year==1900
drop yr1880 yr1885 yr1895 yr1905 yr1910 
sort id year

forv  i=1750(50)1900{
label var fpresence`i' "Years French presence X `i'"   
}

*==============================================================================*


* 1) Clustered SE
*==============================================================================*
eststo clear		
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
estadd scalar states = e(df_a)+1
eststo: test fpresence1850 fpresence1875 fpresence1900
estadd scalar p_val=r(p)

xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* if westelbe==1, fe i(id) cluster(id)
estadd scalar states = e(df_a)+1
eststo: test fpresence1850 fpresence1875 fpresence1900
estadd scalar p_val=r(p)

xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* [aweight=totalpop1750], fe i(id) cluster(id)
estadd scalar states = e(df_a)+1
eststo: test fpresence1850 fpresence1875 fpresence1900
estadd scalar p_val=r(p)

xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, fe i(id) cluster(id)
estadd scalar states = e(df_a)+1
eststo: test fpresence1850 fpresence1875 fpresence1900
estadd scalar p_val=r(p)

esttab using "$output/Table 3 - Clustered SE.txt", p se replace label noobs ///
keep(fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900, relax) ///
cells(b(fmt(3) star) se(par fmt(3))) ///
stats(N states p_val, fmt(0 0 3) labels("Observations" "Number of states" "p-value for joint significance after 1800")) 
*==============================================================================*


* 2) Wild-bootstrap 
*==============================================================================*
eststo clear		
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
eststo: boottest {fpresence1750} {fpresence1800} {fpresence1850} {fpresence1875} {fpresence1900}, boottype(wild) cluster(id) robust seed(123) nograph
mat p2 = (r(p_1), r(p_2), r(p_3), r(p_4), r(p_5))
mat colnames p2= fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900
estadd matrix p2

xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* if westelbe==1, fe i(id) cluster(id)
eststo: boottest {fpresence1750} {fpresence1800} {fpresence1850} {fpresence1875} {fpresence1900}, boottype(wild) cluster(id) robust seed(123) nograph
mat p2 = (r(p_1), r(p_2), r(p_3), r(p_4), r(p_5))
mat colnames p2= fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900
estadd matrix p2

xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* [aweight=totalpop1750], fe i(id) cluster(id)
eststo: boottest {fpresence1750} {fpresence1800} {fpresence1850} {fpresence1875} {fpresence1900}, boottype(wild) cluster(id) robust seed(123) nograph
mat p2 = (r(p_1), r(p_2), r(p_3), r(p_4), r(p_5))
mat colnames p2= fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900
estadd matrix p2

xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, fe i(id) cluster(id)
eststo: boottest {fpresence1750} {fpresence1800} {fpresence1850} {fpresence1875} {fpresence1900}, boottype(wild) cluster(id) robust seed(123) nograph
mat p2 = (r(p_1), r(p_2), r(p_3), r(p_4), r(p_5))
mat colnames p2= fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900
estadd matrix p2

esttab using "$output/Table 3 - Bootstrapped SE.txt", replace ///
keep(fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900, relax) ///
cells(b(fmt(3) pvalue(p2) star)  se(par fmt(2)) p(par({ })) p2(par([ ] ))) ///
addnotes("Clustered standard errors in parenthesis, clustered p-value in braces, wild-bootstrapped p-values in brackets")
*==============================================================================*



* 3) ARTs
*==============================================================================*

capture program drop "$programs/art"

eststo clear

* Column 2		
preserve
keep if westelbe==1
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*  , cluster(id) m(regress) report(fpresence1750)
scalar p_1 = r(pvalue_joint)
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, cluster(id) m(regress) report(fpresence1800)
scalar p_2 = r(pvalue_joint)
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, cluster(id) m(regress) report(fpresence1850)
scalar p_3 = r(pvalue_joint)
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, cluster(id) m(regress) report(fpresence1875)
scalar p_4 = r(pvalue_joint)
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, cluster(id) m(regress) report(fpresence1900)
scalar p_5 = r(pvalue_joint)
restore
mat p2 = (p_1, p_2, p_3, p_4, p_5)
mat colnames p2= fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900
eststo: xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* if westelbe==1, fe i(id) cluster(id)
estadd matrix p2


* Column 4
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, cluster(id) m(regress) report(fpresence1750)
scalar p_1 = r(pvalue_joint)
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, cluster(id) m(regress) report(fpresence1800)
scalar p_2 = r(pvalue_joint)
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, cluster(id) m(regress) report(fpresence1850)
scalar p_3 = r(pvalue_joint)
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, cluster(id) m(regress) report(fpresence1875)
scalar p_4 = r(pvalue_joint)
art urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, cluster(id) m(regress) report(fpresence1900)
scalar p_5 = r(pvalue_joint)
mat p2 = (p_1, p_2, p_3, p_4, p_5)
mat colnames p2= fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900
eststo: xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, fe i(id) cluster(id)
estadd matrix p2


esttab using "$output/Table 3 - Bootstrapped SE.txt", replace ///
keep(fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900, relax) ///
cells(b(fmt(3) pvalue(p2) star)  se(par fmt(2)) p(par({ })) p2(par([ ] ))) ///
addnotes("Clustered standard errors in parenthesis, clustered p-value in braces, ART-based p-values in brackets")

*==============================================================================*

