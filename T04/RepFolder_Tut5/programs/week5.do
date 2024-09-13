/*******************************************************************************
                      Semana 5: Variables instrumentales 
                          Universidad de San Andrés
                              Economía Aplicada
							      					           
*******************************************************************************/

/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment

1) IV

2) IV by hand

3) Hausman Test

4) Sargan test

5) Hansen J-test

6) Weak instruments

*******************************************************************************/


* 0) Set up environment
*==============================================================================*

global main "/Users/tomaspacheco/Library/CloudStorage/GoogleDrive-tpacheco@udesa.edu.ar/Mi unidad/UdeSA/Aplicada2024/Clases/5. IV"
global input "$main/input"
global output "$main/output"
cd "$main"


* 1) IV
*==============================================================================*

* Open the database
use "$input/mroz", clear

* Estimating the model log(wage)=ß0+ß1*educ+µ
reg lwage educ, robust
est store ols

* The estimate for ß1 implies an almost 11% return for another year of education.
/* Next, we use father’s education (fatheduc) as an instrumental variable for educ. 
We have two requirements 
- fatheduc must to be uncorrelated with u
- educ and fatheduc are correlated */

reg educ fatheduc if inlf==1
*reg educ fatheduc if e(sample)==1

*reg educ exper* fatheduc motheduc if inlf==1

/* The t statistic on fatheduc is 9.43, which indicates that educ and fatheduc have a 
statistically significant positive correlation. Fatheduc explains about 17% of the variation 
in educ in the sample.)*/

* Using the instrumental variable:
ivregress 2sls lwage (educ=fatheduc), robust
est store iv
esttab ols iv

/* The IV estimate of the return to education is 5.9%, which is about one-half of the OLS estimate. 
This suggests that the OLS estimate is too high and is consistent with omitted ability bias.
But we should remember that these are estimates from just one sample: we can never know whether 0.109 is above the true return to education, or whether 0.059 is closer to the true return to education.
The 95% confidence interval for ß_1 using OLS is much tighter than the IV’s 95% confidence interval. 
The IV confidence interval actually contains the OLS estimate. We cannot say whether the difference is statistically significant.*/

* We can ask for the first stage of the iv
ivregress 2sls lwage (educ=fatheduc), robust first

** Another example

use "$input/russia", clear

* Consider a least squares regression on the determinants of self-reported health evaluation:
reg evalhl alclmo cmedin belief operat obese smokes totexpr monage if gender==0, robust
est store ols

* IV
ivregress 2sls evalhl alclmo cmedin belief operat smokes totexpr monage (obese = height hipsiz waistc)if gender==0, robust
est store iv

*Comparision
esttab ols iv

* Asking for first stage
ivregress 2sls evalhl alclmo cmedin belief operat smokes totexpr monage (obese =height hipsiz waistc) if gender==0, robust first


* 2) IV by hand
*==============================================================================*

/* We must drop every observation with missing values in at least one of the variables utilized. 
This avoids using information from an individual only in the first stage. */ 
drop if evalhl==. | alclmo==. | cmedin==. | belief==. | operat==. | obese==. | height==. | hipsiz==. | waistc==. | smokes==. | totexpr==. | monage==.

* Run the first
reg obese alclmo cmedin belief operat smokes totexpr monage height hipsiz waistc if gender==0, robust

* Save the fitted values as "obese_hat":
predict obese_hat

* Run the second stage
reg evalhl alclmo cmedin belief operat smokes totexpr monage obese_hat if gender==0, robust
est store iv_hand

* Compare with IV
esttab iv iv_hand

* The values for the slopes are the same!


* 4) Hausman Test
*==============================================================================*

use "$input/card", clear

* Save the IV estimates
ivregress 2sls lwage76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 ( ed76 = nearc4 )
est store iv

* Save the OLS estimates
reg lwage76 ed76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669
est store ols

* Use the command "hausman" indicating first the consistent estimates and then the efficient estimates: 
hausman iv ols

/* The null hypothesis is that there is not systematic difference between the estimates.
If you reject the null hypothesis, the coefficients are different so you should use IV, education is endogenous. If you don’t reject the null hypothesis, you should use OLS, because being the coefficients consistent, ols is the most efficient. */

* ivregress postestimation
ivregress 2sls lwage76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 ( ed76 = nearc4 )
estat endogenous

ivregress 2sls lwage76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 ( ed76 = nearc4 ), robust
estat endogenous

*estat endogenous performs tests to determine whether endogenous regressors in the model are in fact exogenous (conditional on the instrument being exogenous). If the test statistic is significant, then the variables being tested must be treated as endogenous. This is not the case in our example.
* with an unadjusted VCE: the Durbin (1954) and Wu-Hausman statistics
* with a robust VCE, a robust score test (Wooldrigde 1995) and a robust regression-based test

*** Alternatives
*1)
* Run first stage and keep x hat
reg ed76 nearc4 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 if lwage76!=., robust
predict x_hat

* Run OLS regression including X and X hat
reg lwage76 ed76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 x_hat

* If X is exogeneous, then you already have X variability captured so adding the variability of X contained in Z should have no explanatory power.
* Then, under H0, the coefficient of xhat is zero, which implies that X is exogenous, and that is the same as saying that E(X' epsilon) = 0, which was the assumption that governed the H0 of the Hausman test. Rejecting H0, it would be saying that X is endogenous.
test x_hat=0

*2)
* Run the fist stage and predict the residuals
reg ed76 nearc4 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 if lwage76!=., robust
predict res, residual

* Run the original least squares regression, but including the residuals:
reg lwage76 ed76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 res
est store reg_res

* First notice that the coefficients (though not the standard errors) are the same than those obtained using "ivregress":
ivregress 2sls lwage76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 (ed76 = nearc4), robust
est store iv

esttab reg_res iv

/* Finally, the Hausman test consists in testing if the coefficient on the residuals ("res") is null: 
if rejected, then (given that the instruments are valid) "educ" is endogenous.
Else, if res has no effect on Y, the X is exogenous, the instrument is not explaining X's variability since X is already exogenous*/
reg lwage76 ed76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 res, robust
test res=0

** In sum, the Hausman test allows me to see if I effectively removed the correlation between my regressor (previously endogenous) and the error, and test if the estimator is consistent.


* 5) Sargan test
*==============================================================================*

* Estimate by IV and predict the residuals
ivregress 2sls lwage76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 ( ed76 = nearc4a nearc4b), robust
predict resid, residual

* Regress the residuals on all the exogenous variables (instruments and controls) 
reg resid exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 nearc4a nearc4b, robust

* Obtain the R2 and use it to compute the statistic S=nR2
ereturn list
display chi2tail(1,e(N)*e(r2))

/* The null hypothesis is that all moment conditions are valid. If the test is rejected, you cannot determine which the invalid moment conditions are. 
In this case you cannot reject the null hypothesis: the instruments are exogenous*/

ivregress 2sls lwage76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 ( ed76 = nearc4a nearc4b), robust
estat overid


* 6) Hansen J-test
*==============================================================================*

* Estimate by IV and predict the residuals
ivregress 2sls lwage76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 ( ed76 = nearc4a nearc4b), robust
predict resid1, residual

* Regress the residuals on all the exogenous variables (instruments and controls) 
reg resid1 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 nearc4a nearc4b, robust

* Compute the F-statistic from testing that all instruments are jointly zero
test nearc4a=nearc4b=0

/* The overidentifying restriction test statistic is J=mF. 
Under the null hypothesis that all instruments are exogenous, J is distributed Chi-Squared(m-r), where (m-r) is the number of instruments minus the number of endogenous variables */
return list
ereturn list

display chi2tail(1,2*r(F))

* You can also see the results of the test with ivreg2
ivreg2 lwage76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 ( ed76 = nearc4a nearc4b), robust

** Another example
use "$input/russia", clear

* Estimate by IV and predict the residuals
ivregress 2sls evalhl alclmo cmedin belief operat (obese =height hipsiz waistc) smokes totexpr monage if gender==0, robust
predict resid2, residual

* Regress the residuals on all the exogenous variables (instruments and controls) 
reg resid2 alclmo cmedin belief operat height hipsiz waistc smokes totexpr monage, robust

* Compute the F-statistic from testing that all instruments are jointly zero
test height==hipsiz==waistc==0

/* The overidentifying restriction test statistic is J=mF. 
Under the null hypothesis that all instruments are exogenous, J is distributed Chi-Squared(m-r), where (m-r) is the number of instruments minus the number of endogenous variables */
return list
ereturn list

display chi2tail(2,3*r(F))

ivreg2 evalhl alclmo cmedin belief operat (obese =height hipsiz waistc) smokes totexpr monage if gender==0, robust


* 7) Weak instruments
*==============================================================================*

use "$input/card", clear
* Estimate the FIRST STAGE
reg ed76 nearc4a nearc4b exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 if lwage76!=., robust

* Test (you would like F>10)
test nearc4a=nearc4b=0

* Montiel and Pflueger (2013). For details, see "A robust test for weak instruments in Stata" by Pflueger and Wang, 2015, Stata Journal.
*ssc install weakivtest

ivregress 2sls lwage76 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 ( ed76 = nearc4 ), first
weakivtest

* If it is only one instrument, the t statistic from the regression on x shuld be at least 3.2
reg ed76 nearc4 exp76 exp762 black smsa76r reg76r smsa66r reg662 - reg669 if lwage76!=., robust


