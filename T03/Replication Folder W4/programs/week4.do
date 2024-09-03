/*******************************************************************************
                   Semana 4: Fuentes de sesgo e imprecisión 
                          Universidad de San Andrés
                              Economía Aplicada
*******************************************************************************/

/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment

1) Multicollinearity

2) A "fictional" example for omitted variables
*******************************************************************************/


* 0) Set up environment
*==============================================================================*

global main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T03/Replication Folder W4"
global input "$main/input"
global output "$main/output"

cd "$main"

* 1) Multicollinearity
*==============================================================================*

/* High (but not perfect) correlation between two or more independent variables is called multicollinearity.
It is important to be very clear on one thing: multicollinearity violates none of our assumptions. 
A case where R_j^2 ( ) is close to one is not a violation of the assumption of no perfect collinearity.
When we say that multicollinearity arises for estimating ß_j when R_j^2 is "close" to one, we put "close" 
in quotation marks because there is no absolute number that we can cite to conclude that multicollinearity is a problem.
What ultimately matters is how big (ß_j ) ^ is in relation to its standard deviation.
A high degree of correlation between certain independent variables can be irrelevant as to how well we can estimate 
other parameters in the model. Consider a model with three independent variables, where x_2 and x_3 are highly correlated. 
Then Var(ß ^_2) and Var(ß ^_3) may be large. But the amount of correlation between x_2 and x_3 has no direct effect on 
Var(ß ^_1). If ß_1 is the parameter of interest, we do not really care about the amount of correlation between x_2 and x_3.
When two independent variables are highly correlated, it can be difficult to estimate the partial effect of each. 
With a small change of an observation, the change on the coefficients could be very large.
If you are not interested on the coefficients, multicollinearity is not a problem because the estimation of y (y_hat) 
is correct.*/

* Let's use a fictional example
clear
set obs 100
set seed 1233
gen intelligence = int(rnormal(100,20))

/* We set the standard error of this variable so the correlation between education and intelligence is high (0.90 approximate).*/

gen education = int(intelligence/10 + rnormal(0,1))
corr education intelligence

gen a = int(rnormal(10,3))
gen b = int(rnormal(5,1))
gen u = int(rnormal(0,1))

gen wage = 3*intelligence + a + 2*b + u

* Two different regressions
reg wage intelligence a b
predict y_hat_1

* The command estimates est store saves the current (active) estimation results.
est store ols11

* Include education that is not in the Data Generating Process and it is highly correlated with intelligence. Note that coefficients and SE for a and b do not change, but the SE for the coefficient of intelligence changes, and a lot.
reg wage education intelligence a b
predict y_hat_2

* Store the results under the name ols12.
est store ols12

* They predict the same y_hat
corr y_hat_1 y_hat_2  

* Using the commands suest and esttab we can compare the results of the two ols exercise
esttab ols11 ols12
suest ols11 ols12
*suest ols11 ols12, robust

* Tests
test [ols11_mean]intelligence = [ols12_mean]intelligence
test [ols11_mean]a = [ols12_mean]a
test [ols11_mean]b = [ols12_mean]b


/* When multicollinearity is high, a small change of an observation can produce a large change on the coefficients. 
Let's see an example. */
reg wage education intelligence a b

* The command estimates store name saves the current (active) estimation results under the name ols21.
est store ols21

* We can replace the value of the first observation 
replace intelligence = intelligence+15 in 1 

* We now estimate the same equation and store the results under the name ols22.
reg wage education intelligence a b
est store ols22

* Using the commands suest and esttab we can compare the results of the two ols exercise
esttab ols21 ols22
suest ols21 ols22

* Tests
test [ols21_mean]intelligence=[ols22_mean]intelligence
test [ols21_mean]a=[ols22_mean]a
test [ols21_mean]b=[ols22_mean]b

* All coefficients are significantly different between both regressions.




* 2) A "fictional" example for omitted variables
*==============================================================================*


/* We will create values for some variables, using the "actual" values of the linear parameters involved. 
Then we will try to retrieve those parameters using OLS, what will let us experiment with some basic properties.
Let's generate i.i.d. data on wages, education, intelligence, two explanatory variables uncorrelated with 
education and intelligence but correlated with wages (a and b), and finally a variable (c) totally uncorrelated 
with all the former variables.*/
clear
set obs 100
set seed 1234

/* The variable intelligence will be the IQ of the individuals. IQs have approximately a normal distribution 
centered in 100 with a standard deviation of 20:*/
gen intelligence = int(rnormal(100,20))
hist intelligence, norm

/* Since more intelligent people is expected to study more, the years of education will be equal to the intelligence
(over 10) plus a normally distributed noise with mean 0 and deviation 1. Finally, we will keep only the integer part 
of the numbers:*/
gen education = int(intelligence/10 + rnormal(0,1))
hist education, norm

/* I will stop repeating "enter browse to see the results". Then, feel free to do so whenever you want. 
Variable a (b) will be normally distributed with mean 10 (5) and standard deviation 3 (1). 
Variable "c" will be normally distributed with mean 150 and standard deviation 3.*/
gen a = int(rnormal(10, 3))
gen b = int(rnormal(5, 1))
gen c = int(rnormal(150, 3))

* The unobserved error term "u" will be normally distributed with mean 0 and standard deviation 1:
gen u = int(rnormal(0,1))
hist u, norm

* Descriptive statistics table of the variables we have just created.
sum intelligence education a b c u, sep(6)

/* Wages will be the result of "intelligence" multiplied by 3, plus variables "a" and "b" multiplied 
by 1 and 2 respectively, plus the unobserved error term "u":*/
gen wage = 3*intelligence + a + 2*b + u

/* We estimate the "right" equation. The command for OLS is "reg" followed by the dependent variable 
and then the list of explanatory variables. We will include the option "robust", which indicates the
use of robust variance estimates:*/
reg wage intelligence a b
est store ols1

/* The estimated coefficients are accurately near the true values. Notice that "education" does not "affect" wages. 
Then, if we included "education" and "intelligence" in the regression, then the former should not appear with a 
significative coefficient:*/
reg wage education intelligence
est store ols2

/* Education is correlated with intelligence. Thus, if we forgot to include "intelligence" then the coefficient 
on "education" would be different from zero at reasonable confidence levels:*/ 
reg wage education
est store ols3

/* The reason is that in the last equation "intelligence" is in the error term (because it "affects" wages but 
it is not included in the regression), and "intelligence" is correlated with "education". 
Thus, the orthogonality condition is not satisfied.
 
The exclusion of "a" and "b" does not violate the exogeneity condition. 
Since "intelligence" is not correlated with "a" and "b", its coefficient should remain consistent and unbiased:*/
reg wage intelligence
est store ols4

* Including "a" and "b" should decrease the standard deviation of the coefficient on "intelligence":
reg wage intelligence a b

* Finally, let's see the effect of including an "irrelevant" variable ("c") in the "right" equation:
reg wage intelligence a b c
est store ols5

/* Compared to the "right" equation", in the regression that includes an irrelevant variable the standard errors are lower. Unless intelligence, a and b are uncorrelated in the sample with c, including c increases the variance for the estimators:*/
reg wage intelligence a b

* All the results
esttab ols1 ols2 ols3 ols4 ols5 

