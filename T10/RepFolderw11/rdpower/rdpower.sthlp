{smcl}
{* *! version 0.1 08Jun2016}{...}
{viewerjumpto "Syntax" "rdpower##syntax"}{...}
{viewerjumpto "Description" "rdpower##description"}{...}
{viewerjumpto "Options" "rdpower##options"}{...}
{viewerjumpto "Examples" "rdpower##examples"}{...}
{viewerjumpto "Saved results" "rdpower##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:rdpower} {hline 2} Power calculation for RD designs.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdpower} {it:depvar} {it:runvar} {ifin} 
[{cmd:,} 
{cmd:c(}{it:#}{cmd:)} 
{cmd:tau(}{it:#}{cmd:)} 
{cmd:slevel(}{it:#}{cmd:)} 
{cmd:nsample(}{it:# #}{cmd:)} 
{cmd:plot} 
{cmd:graph_range(}{it:# #}{cmd:)} 
{cmd:graph_step(}{it:#}{cmd:)} 
{cmd:graph_options(}{it:graph_opt}{cmd:)} 
{cmd:covs(}{it:covars}{cmd:)}
{cmd:deriv(}{it:#}{cmd:)}
{cmd:p(}{it:#}{cmd:)} 
{cmd:q(}{it:#}{cmd:)}
{cmd:h(}{it:# #}{cmd:)} 
{cmd:b(}{it:# #}{cmd:)}
{cmd:rho(}{it:#}{cmd:)}
{cmd:kernel(}{it:kernelfn}{cmd:)}
{cmd:bwselect(}{it:bwmethod}{cmd:)}
{cmd:vce(}{it:vcetype [vceopt1 vceopt2]}{cmd:)}
{cmd:scalepar(}{it:#}{cmd:)}
{cmd:scaleregul(}{it:#}{cmd:)}
{cmd:all} 
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdpower} uses {cmd:rdrobust} to calculate power for Regression Discontinuity designs using conventional and robust bias corrected standard errors. See
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_ECMA.pdf":Calonico, Cattaneo and Titiunik (2014a)}
,
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_Stata.pdf":Calonico, Cattaneo and Titiunik(2014b)}
,
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Farrell-Titiunik_2016_wp.pdf":Calonico, Cattaneo, Farrell and Titiunik(2016a)}
and
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Farrell-Titiunik_2016_Stata.pdf":Calonico, Cattaneo, Farrell and Titiunik(2016b)}
for formulas and details.{p_end}



{marker options}{...}
{title:Options}

{p 4 8}{cmd:c(}{it:#}{cmd:)} specifies the RD cutoff for {it:indepvar}.
Default is {cmd:c(0)}.{p_end}

{p 4 8}{cmd:tau(}{it:#}{cmd:)} specifies the treatment effect under the alternative at which the power function is evaluated. The default is half the standard deviation of the outcome for the untreated group.
Default is {cmd:c(0)}.{p_end}

{p 4 8}{cmd:slevel(}{it:#}{cmd:)} specifies the significance level for the power function.
Default is {cmd:slevel(.05)}.{p_end}

{p 4 8}{cmd:nsample(}{it:# #}{cmd:)} sets the sample size at each side of the cutoff for power calculation. The first number is the sample size to the left of the cutoff and the second number is the sample size to the right.
Default values are the sample sizes inside the chosen bandwidth.

{p 4 8}{cmd:plot} plots the power function using the conventional and robust bias corrected standard errors from {cmd:rdrobust}.

{p 4 8}{cmd:graph_range(}{it:# #}{cmd:)} specifies the range of the plot when {cmd:plot} option is used.
Default range is [-1.5*tau ; 1.5*tau].

{p 4 8}{cmd:graph_step(}{it:#}{cmd:)} specifies the step increment of the plot when {cmd:plot} option is used.
Default range is 0.2*range.

{p 4 8}{cmd:graph_step(}{it:#}{cmd:)} specifies the graph options (title, axes titles, etc) to be passed to the plot when {cmd:plot} option is used.

{p 4 8 }The following options can be passed to {cmd:rdrobust}:

{p 4 8}{cmd:covs(}{it:covars}{cmd:)} specifies additional covariates to be used for estimation and inference.{p_end}

{p 4 8}{cmd:deriv(}{it:#}{cmd:)} specifies the order of the derivative of the regression functions to be estimated.
Default is {cmd:deriv(0)}. Setting {cmd:deriv(1)} results in estimation of a Kink RD design (up to scale).{p_end}

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the local polynomial used to construct the point estimator.
Default is {cmd:p(1)} (local linear regression).{p_end}

{p 4 8}{cmd:q(}{it:#}{cmd:)} specifies the order of the local polynomial used to construct the bias correction.
Default is {cmd:q(2)} (local quadratic regression).{p_end}

{p 4 8}{cmd:h(}{it:# #}{cmd:)} specifies the main bandwidth ({it:h}) used to construct the RD point estimator. If not specified, bandwidth {it:h} is computed by the companion command {help rdbwselect:rdbwselect}.
If two bandwidths are specified, the first bandwidth is used for the data below the cutoff and the second bandwidth is used for the data above the cutoff.{p_end}

{p 4 8}{cmd:b(}{it:# #}{cmd:)} specifies the bias bandwidth ({it:b}) used to construct the bias-correction estimator. If not specified, bandwidth {it:b} is computed by the companion command {help rdbwselect:rdbwselect}.
If two bandwidths are specified, the first bandwidth is used for the data below the cutoff and the second bandwidth is used for the data above the cutoff.{p_end}

{p 4 8}{cmd:rho(}{it:#}{cmd:)} specifies the value of {it:rho}, so that the bias bandwidth {it:b} equals {it:b}={it:h}/{it:rho}.
Default is {cmd:rho(1)} if {it:h} is specified but {it:b} is not.{p_end}

{p 4 8}{cmd:kernel(}{it:kernelfn}{cmd:)} specifies the kernel function used to construct the local-polynomial estimator(s). Options are: {opt tri:angular}, {opt epa:nechnikov}, and {opt uni:form}.
Default is {cmd:kernel(triangular)}.{p_end}

{p 4 8}{cmd:bwselect(}{it:bwmethod}{cmd:)} specifies the bandwidth selection procedure to be used. By default it computes both {it:h} and {it:b}, unless {it:rho} is specified, in which case it only computes {it:h} and sets {it:b}={it:h}/{it:rho}.
Options are:{p_end}
{p 8 12}{opt mserd} one common MSE-optimal bandwidth selector for the RD treatment effect estimator.{p_end}
{p 8 12}{opt msetwo} two different MSE-optimal bandwidth selectors (below and above the cutoff) for the RD treatment effect estimator.{p_end}
{p 8 12}{opt msesum} one common MSE-optimal bandwidth selector for the sum of regression estimates (as opposed to difference thereof).{p_end}
{p 8 12}{opt msecomb1} for min({opt mserd},{opt msesum}).{p_end}
{p 8 12}{opt msecomb2} for median({opt msetwo},{opt mserd},{opt msesum}), for each side of the cutoff separately.{p_end}
{p 8 12}{opt cerrd} one common CER-optimal bandwidth selector for the RD treatment effect estimator.{p_end}
{p 8 12}{opt certwo} two different CER-optimal bandwidth selectors (below and above the cutoff) for the RD treatment effect estimator.{p_end}
{p 8 12}{opt cersum} one common CER-optimal bandwidth selector for the sum of regression estimates (as opposed to difference thereof).{p_end}
{p 8 12}{opt cercomb1} for min({opt cerrd},{opt cersum}).{p_end}
{p 8 12}{opt cercomb2} for median({opt certwo},{opt cerrd},{opt cersum}), for each side of the cutoff separately.{p_end}
{p 8 12}Note: MSE = Mean Square Error; CER = Coverage Error Rate.{p_end}
{p 8 12}Default is {cmd:bwselect(mserd)}. For details on implementation see
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_ECMA.pdf":Calonico, Cattaneo and Titiunik (2014a)},
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Farrell_2016_wp.pdf":Calonico, Cattaneo and Farrell (2016a)},
and {browse "http://www-personal.umich.edu/~cattaneo/papers/Cattaneo-Farrell-Titiunik_2016_wp.pdf":Calonico, Cattaneo, Farrell and Titiunik (2016)},
and the companion software articles.{p_end}

{p 4 8}{cmd:vce(}{it:vcetype [vceopt1 vceopt2]}{cmd:)} specifies the procedure used to compute the variance-covariance matrix estimator.
Options are:{p_end}
{p 8 12}{cmd:vce(nn }{it:[nnmatch]}{cmd:)} for heteroskedasticity-robust nearest neighbor variance estimator with {it:nnmatch} indicating the minimum number of neighbors to be used.{p_end}
{p 8 12}{cmd:vce(hc0)} for heteroskedasticity-robust plug-in residuals variance estimator without weights.{p_end}
{p 8 12}{cmd:vce(hc1)} for heteroskedasticity-robust plug-in residuals variance estimator with {it:hc1} weights.{p_end}
{p 8 12}{cmd:vce(hc2)} for heteroskedasticity-robust plug-in residuals variance estimator with {it:hc2} weights.{p_end}
{p 8 12}{cmd:vce(hc3)} for heteroskedasticity-robust plug-in residuals variance estimator with {it:hc3} weights.{p_end}
{p 8 12}{cmd:vce(nncluster }{it:clustervar [nnmatch]}{cmd:)} for cluster-robust nearest neighbor variance estimation using with {it:clustervar} indicating the cluster ID variable and {it: nnmatch} matches indicating the minimum number of neighbors to be used.{p_end}
{p 8 12}{cmd:vce(cluster }{it:clustervar}{cmd:)} for cluster-robust plug-in residuals variance estimation with degrees-of-freedom weights and {it:clustervar} indicating the cluster ID variable.{p_end}
{p 8 12}Default is {cmd:vce(nn 3)}.{p_end}

{p 4 8}{cmd:scalepar(}{it:#}{cmd:)} specifies scaling factor for RD parameter of interest. This option is useful when the estimator of interest requires a known multiplicative factor rescaling (e.g., Sharp Kink RD).
Default is {cmd:scalepar(1)} (no rescaling).{p_end}

{p 4 8}{cmd:scaleregul(}{it:#}{cmd:)} specifies scaling factor for the regularization term added to the denominator of the bandwidth selectors. Setting {cmd:scaleregul(0)} removes the regularization term from the bandwidth selectors.
Default is {cmd:scaleregul(1)}.{p_end}



    {hline}
	
		
{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:. use rdrobust_senate.dta}{p_end}

{p 4 8}Power calculation against an alternative hypothesis of tau = 5{p_end}
{p 8 8}{cmd:. rdpower vote margin, tau(5)}{p_end}

{p 4 8}Power calculation with covariates{p_end}
{p 8 8}{cmd:. rdpower vote margin, covs(population termshouse termssenate)}{p_end}

{p 4 8}Power calculation with user-specified bandwidths{p_end}
{p 8 8}{cmd:. rdpower vote margin, h(16 18)}{p_end}

{p 4 8}Power function plot with default options{p_end}
{p 8 8}{cmd:. rdpower vote margin, plot}{p_end}

{p 4 8}Power function plot with user-specified range and step{p_end}
{p 8 8}{cmd:. rdpower vote margin, plot graph_range(-9 9) graph_step(2)}{p_end}

{p 4 8}Power function plot with user-specified options{p_end}
{p 8 8}{cmd:. rdpower vote margin, plot graph_range(-9 9) graph_step(2) graph_options(title(Power function) xline(0, lcolor(black) lpattern(dash)) xtitle(tau) ytitle(power))}{p_end}

{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rdpower} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(power_conv)}}power against tau using conventional standard error{p_end}
{synopt:{cmd:r(power_rbc)}}power against tau using robust bias corrected standard error{p_end}
{synopt:{cmd:r(se_conv)}}conventional standard error{p_end}
{synopt:{cmd:r(se_rbc)}}robust bias corrected standard error{p_end}
{synopt:{cmd:r(tau)}}treatment effect under alternative hypothesis{p_end}
{synopt:{cmd:r(h_l)}}bandwidth used for estimation of the regression function below the cutoff{p_end}
{synopt:{cmd:r(h_r)}}bandwidth used for estimation of the regression function above the cutoff{p_end}
{synopt:{cmd:r(N_h_l)}}effective number of observations (given by the bandwidth h_l) used to the left of the cutoff{p_end}
{synopt:{cmd:r(N_h_r)}}effective number of observations (given by the bandwidth h_r) used to the right of the cutoff{p_end}
{synopt:{cmd:r(slevel)}}significance level used in power function{p_end}



{title:References}

{p 4 8}Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik. 2016a. Regression Discontinuity Designs using Covariates.
Working Paper.
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Farrell-Titiunik_2016_wp.pdf"}.{p_end}

{p 4 8}Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik. 2016b. rdrobust: Software for Regression Discontinuity Designs.
Working Paper.
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Farrell-Titiunik_2016_Stata.pdf"}.{p_end}

{p 4 8}Calonico, S., M. D. Cattaneo, and R. Titiunik. 2014a. Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs.
{it:Econometrica} 82(6): 2295-2326.
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_ECMA.pdf"}.{p_end}

{p 4 8}Calonico, S., M. D. Cattaneo, and R. Titiunik. 2014b. Robust Data-Driven Inference in the Regression-Discontinuity Design.
{it:Stata Journal} 14(4): 909-946. 
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_Stata.pdf"}.{p_end}

{title:Authors}

{p 4 8}Matias D. Cattaneo, University of Michigan, Ann Arbor, MI.
{browse "mailto:cattaneo@umich.edu":cattaneo@umich.edu}.

{p 4 8}Gonzalo Vazquez-Bare, University of Michigan, Ann Arbor, MI.
{browse "mailto:gvazquez@umich.edu":gvazquez@umich.edu}.


