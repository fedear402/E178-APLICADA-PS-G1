/*******************************************************************************

RDPOWER: power calculation for Regression Discontinuity Designs

*!version 0.01 09-Jun-2016

Authors: Matias Cattaneo, Gonzalo Vazquez-Bare

*******************************************************************************/

capture program drop rdpower
program define rdpower, rclass
	syntax varlist (min=2 max=2) [if] [in] [, c(real 0) tau(numlist max=1) slevel(real .05) nsample(string) plot ///
											  graph_range(string) graph_step(numlist max=1) graph_options(string) ///
											  covs(string) deriv(real 0) ///
											  p(real 1) q(real 0) h(string) b(string) rho(real 0) ///
											  kernel(string) bwselect(string) vce(string) ///
											  scalepar(real 1) scaleregul(real 1) ]


	****************************************************************************
	** Options and default values

	tokenize `varlist'
	local y `1' 
	local x `2'

	if "`nsample'" != ""{
		tokenize `nsample'
		local n_l = `1'
		local n_r = `2'
		
		capture confirm integer number `1'
		if _rc>0{
			di as error "sample sizes have to be integers"
			exit 198
		}
		capture confirm integer number `2'
		if _rc>0{
			di as error "sample sizes have to be integers"
			exit 198
		}
		
		if `1'<=0 | `2'<=0{
			di as error "sample sizes have to be >0"
			exit 198
		}
	}
	
	if "`covs'" != ""{
		local covs_opt "covs(`covs')"
	}
	
	if "`h'" != ""{
		local h_opt "h(`h')"
	}
	
	if "`b'" != ""{
		local b_opt "b(`b')"
	}
	
	if "`kernel'" != ""{
		local kernel_opt "kernel(`kernel')"
	}
	
	if "`bwselect'" != ""{
		local bwselect_opt "bwselect(`bwselect')"
	}
	
	if "`vce'" != ""{
		local vce_opt "vce(`vce')"
	}
	
	
	****************************************************************************
	** Power calculation

	 qui rdrobust `y' `x' `if' `in', c(`c') all `covs_opt' deriv(`deriv') 	 ///
									p(`p') q(`q') `h_opt' `b_opt' rho(`rho') ///
									`kernel_opt' `bwselect_opt' `vce_opt' 	 ///
									scalepar(`scalepar') scaleregul(`scaleregul') ///
	

	if "`tau'" == ""{
		local hl = e(h_l)
		qui sum `y' if `c'-`hl'<=`x' & `x'<`c'
		local sd0 = r(sd)
		local tau = 0.5*`sd0'
	}
	
	if "`nsample'" == ""{
		local n_l = e(N_h_l)
		local n_r = e(N_h_r)
	}
	
	mat Vl_cl = e(V_cl_l)
	mat Vr_cl = e(V_cl_r)
	mat Vl_rb = e(V_rb_l)
	mat Vr_rb = e(V_rb_r)
	
	local se_conv = sqrt(e(N_h_l)*Vl_cl[1,1]/`n_l' + e(N_h_r)*Vr_cl[1,1]/`n_r')
	local se_rbc = sqrt(e(N_h_l)*Vl_rb[1,1]/`n_l' + e(N_h_r)*Vr_rb[1,1]/`n_r')

	local power_conv = 1 - normal((`tau')/`se_conv'+invnormal(1-`slevel'/2)) ///
							+ normal((`tau')/`se_conv'-invnormal(1-`slevel'/2))
						
	local power_rbc = 1 - normal((`tau')/`se_rbc'+invnormal(1-`slevel'/2)) ///
							+ normal((`tau')/`se_rbc'-invnormal(1-`slevel'/2))

	foreach r of numlist 1 2 5 8 {
		local r1 = `r'/10
		local te = `r1'*`tau'
		local power_conv`r' = 1 - normal((`te')/`se_conv'+invnormal(1-`slevel'/2)) ///
							+ normal((`te')/`se_conv'-invnormal(1-`slevel'/2))
							
		local power_rbc`r' = 1 - normal((`te')/`se_rbc'+invnormal(1-`slevel'/2)) ///
							+ normal((`te')/`se_rbc'-invnormal(1-`slevel'/2))
	}


	****************************************************************************
	** Descriptive statistics for display

	* Left panel

	local N_l = e(N_l)
	local N_r = e(N_r)
	if "`nsample'" != ""{
		local N_h_l = `n_l'
		local N_h_r = `n_r'
	}
	else {
		local N_h_l = e(N_h_l)
		local N_h_r = e(N_h_r)
	}
	local p = e(p)
	local q = e(q)
	local h_l = e(h_l)
	local h_r = e(h_r)
	local b_l = e(b_l)
	local b_r = e(b_r)
	local rho_l = `h_l'/`b_l'
	local rho_r = `h_r'/`b_r'

	* Right panel

	local N = e(N)
	local bwselect = e(bwselect)
	local kernel_type = e(kernel)
	local vce_type = e(vce_select)


	****************************************************************************
	** Display output

		disp ""
		disp as text "{ralign 21: Cutoff c = `c'}"      _col(22) " {c |} " _col(23) in gr "Left of " in yellow "c"  _col(36) in gr "Right of " in yellow "c" _col(61) as text "Number of obs = "  in yellow %10.0f `N'
		disp as text "{hline 22}{c +}{hline 22}"                                                                                                             _col(61) as text "BW type       = "  in yellow "{ralign 10:`bwselect'}" 
		disp as text "{ralign 21:Number of obs}"        _col(22) " {c |} " _col(23) as result %9.0f `N_l'       _col(37) %9.0f  `N_r'                        _col(61) as text "Kernel        = "  in yellow "{ralign 10:`kernel_type'}" 
		disp as text "{ralign 21:Eff. Number of obs}"   _col(22) " {c |} " _col(23) as result %9.0f `N_h_l'     _col(37) %9.0f  `N_h_r'                      _col(61) as text "VCE method    = "  in yellow "{ralign 10:`vce_type'}" 
		disp as text "{ralign 21:Order loc. poly. (p)}" _col(22) " {c |} " _col(23) as result %9.0f `p'    		_col(37) %9.0f  `p'         				 _col(61) as text "tau           = "  in yellow %10.3f `tau'
		disp as text "{ralign 21:Order bias (q)}"       _col(22) " {c |} " _col(23) as result %9.0f `q'         _col(37) %9.0f  `q'                              
		disp as text "{ralign 21:BW loc. poly. (h)}"    _col(22) " {c |} " _col(23) as result %9.3f `h_l'       _col(37) %9.3f  `h_r'                                   
		disp as text "{ralign 21:BW bias (b)}"          _col(22) " {c |} " _col(23) as result %9.3f `b_l'       _col(37) %9.3f  `b_r'
		disp as text "{ralign 21:rho (h/b)}"            _col(22) " {c |} " _col(23) as result %9.3f `rho_l'     _col(37) %9.3f  `rho_r'
		if ("`cluster'"!="") {
			disp in smcl in gr "{ralign 21:Number of clusters}"   _col(22) " {c |} " _col(23) as result %9.0f g_l   _col(37) %9.0f  g_r                         
		}
		disp ""
		
		di as text _newline "Outcome: " as res "`y'" as text ". Running variable: " as res "`x'" as text "."

		di as text _newline "Power against:" _col(25) as text "0.1*tau = "  	_col(39) "0.2*tau = " 		_col(53) "0.5*tau = " 		_col(67) "0.8*tau = " 		_col(82) "tau = "
		di 									 _col(27) as result %7.3f 0.1*`tau' _col(41) %7.3f 0.2*`tau' 	_col(55) %7.3f 0.5*`tau' 	_col(69) %7.3f 0.8*`tau' 	_col(80) %7.3f `tau'

		di as text "{hline 22}{c TT}{hline 63}"
		di as text "{ralign 21:Conventional}"			_col(22) " {c |} " _col(29) as result  %5.3f `power_conv1' _col(43) %5.3f `power_conv2' _col(57) %5.3f `power_conv5' _col(71) %5.3f `power_conv8' _col(82) %5.3f `power_conv'
		di as text "{ralign 21:Robust bias-corrected}"	_col(22) " {c |} " _col(29) as result  %5.3f `power_rbc1'  _col(43) %5.3f `power_rbc2'  _col(57) %5.3f `power_rbc5'  _col(71) %5.3f `power_rbc8'  _col(82) %5.3f `power_rbc'
		di as text "{hline 22}{c BT}{hline 63}"

		
		
	****************************************************************************
	** Power function plot

	if "`plot'" != "" {
		if "`graph_range'" != ""{
			tokenize `graph_range'
			local left `1'
			local right `2'
		}
		else {
			local left = -1.5*`tau'
			local right = 1.5*`tau'
			local left = round(`left',.1)
			local right = round(`right',.1)
		}
		if "`graph_step'" != ""{
			local step `graph_step'
		}
		else {
			local step = (`right'-`left')/5
		}
		if "`graph_options'" == "" {
			twoway (function y = 1 - normal((x)/`se_conv'+invnormal(1-`slevel'/2)) ///
								 + normal((x)/`se_conv'-invnormal(1-`slevel'/2)), ///
						range(`left' `right')) ///
				   (function y = 1 - normal((x)/`se_rbc'+invnormal(1-`slevel'/2)) ///
								 + normal((x)/`se_rbc'-invnormal(1-`slevel'/2)), ///
						range(`left' `right')), ///
			   xline(`tau', lpattern(shortdash) lwidth(thin)) ///
			   xline(0, lpattern(solid) lwidth(thin) lcolor(gray)) ///
			   yline(`slevel', lpattern(shortdash) lcolor(black) lwidth(thin)) ///
			   legend(label(1 "conventional") label(2 "robust bias corrected"))	///
			   ytitle("power") xtitle("tau") xlabel(`left'(`step')`right') ///
			   note("Power function for N_l = `N_h_l', N_r = `N_h_r', alpha = `slevel' (horizontal dashed line).")
		}
		else {
			twoway (function y = 1 - normal((x)/`se_conv'+invnormal(1-`slevel'/2)) ///
								 + normal((x)/`se_conv'-invnormal(1-`slevel'/2)), ///
						range(`left' `right')) ///
				   (function y = 1 - normal((x)/`se_rbc'+invnormal(1-`slevel'/2)) ///
								 + normal((x)/`se_rbc'-invnormal(1-`slevel'/2)), ///
						range(`left' `right')), ///
			   legend(label(1 "conventional") label(2 "robust bias corrected"))	///
			   `graph_options'
		}
	}

	****************************************************************************
	** Return values

	return scalar power_conv = `power_conv'
	return scalar power_rbc = `power_rbc'
	return scalar se_conv = `se_conv'
	return scalar se_rbc = `se_rbc'
	return scalar tau = `tau'
	return scalar h_l = `h_l'
	return scalar h_r = `h_r'
	return scalar N_h_l = `N_h_l'
	return scalar N_h_r = `N_h_r'
	return scalar slevel = `slevel'

end
