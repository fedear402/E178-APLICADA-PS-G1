/*******************************************************************************
                          Semana 3: Problem Set 2 

                          Universidad de San Andrés
                              Economía Aplicada
							       								2024			
*******************************************************************************/
gl main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T02/PS2"
gl input "$main/input"
gl output "$main/output"
use "$input/measures.dta", clear 
global covs_eva	"male i.eva_fu" 
global covs_ent	"male i.ent_fu"
label var treat "Point Estimate"
label var b_tot_cog1_st "Bayley: Cognitive"
label var b_tot_lr1_st "Bayley: Receptive language"
label var b_tot_le1_st "Bayley: Expressive language"
label var b_tot_mf1_st "Bayley: Fine motor"
label var mac_words1_st "MacArthur: Words the child can say"
label var mac_phrases1_st "MacArthur: Complex phrases the child can say"
label var bates_difficult1_st"ICQ: Difficult (-)"
label var bates_unsociable1_st "ICQ: Unsociable (-)"
label var bates_unstoppable1_st "ICQ: Unstoppable (-)"
label var roth_inhibit1_st "ECBQ: Inhibitory control"
label var roth_attention1_st "ECBQ:: Attentional focusing"
label var fci_play_mat_type1_st "FCI: Number of types of play materials"
label var Npaintbooks1_st "FCI:Number of coloring and drawing books"
label var Nthingsmove1_st "FCI: Number of toys to learn movement" 
label var Ntoysshape1_st "FCI: Number of toys to learn shapes" 
label var Ntoysbought1_st "FCI: Number of shop-bought toys"
label var fci_play_act1_st "FCI: Number of types of play activities in last 3 days"
label var home_stories1_st "FCI: Number of times told a story to child in last 3 days"
label var home_read1_st "FCI: Number of times read to child in last 3 days"
label var home_toys1_st "FCI: Number of times played with toys in last 3 days"
label var home_name1_st "FCI: Number of times named things to child in last 3 days"
*==============================================================================*
scalar hipotesis=21
scalar signif = 0.05
scalar i = 1
mat p_values = J(21,1,.)
*==============================================================================*



******************************************************************************* 
* PANEL A (Child's cognitive skills at follow up) 
******************************************************************************* 
eststo clear
local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
foreach y of local bayley{
	local append append 
	if "`y'"=="b_tot_cog" local append replace 
		cap drop V*
		reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
		eststo: test treat = 0
		estadd scalar p_value = r(p)
		estadd scalar corr_p_value = min(1,r(p)*hipotesis)		
		mat p_values[i,1]=r(p)
	scalar i = i + 1	
	} 

local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)	
	mat p_values[i,1]=r(p)
scalar i = i + 1	
} 

esttab using "$output/PanelA_bonferroni.rtf", replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel A. Child’s cognitive skills at follow-up") ///
collabels("") nonumbers ///
eqlabels("Point Estimate" "SE") ///
stats(N p_value corr_p_value, /// 
labels("Sample size" "p-value" "Bonferroni") ) 


******************************************************************************* 
* PANEL B (Child's socio-emotional skills at follow up) 
******************************************************************************* 
eststo clear
local bates "bates_difficult bates_unsociable bates_unstoppable" 
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)
	mat p_values[i,1]=r(p)
scalar i = i + 1				
} 

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)
	mat p_values[i,1]=r(p)
scalar i = i + 1	
} 

esttab using "$output/PanelB_bonferroni.rtf", replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel B. Child’s socio-emotional skills at follow-up") ///
collabels("") nonumbers ///
eqlabels("Point Estimate" "SE") ///
stats(N p_value corr_p_value, /// 
labels("Sample size" "p-value" "Bonferroni") ) 

******************************************************************************* 
* PANEL C (Material investments)  
******************************************************************************* 
eststo clear
local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)	
	mat p_values[i,1]=r(p)
scalar i = i + 1	
} 

esttab using "$output/PanelC_bonferroni.rtf", replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel C. Material investments at follow-up") ///
collabels("") nonumbers ///
eqlabels("Point Estimate" "SE") ///
stats(N p_value corr_p_value, /// 
labels("Sample size" "p-value" "Bonferroni") ) 

******************************************************************************* 
* PANEL D (Time investments)  
******************************************************************************* 
eststo clear
local fcitime "fci_play_act home_stories home_read home_toys home_name"
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)
	mat p_values[i,1]=r(p)
scalar i = i + 1	
}


esttab using "$output/PanelD_bonferroni.rtf", replace label noobs ///
keep(treat, relax) nonumbers  ///
cells( b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel D. Time investments at follow-up") ///
collabels("") ///
eqlabels("Point Estimate" "SE") ///
stats(N p_value corr_p_value alpha_corr, /// 
labels("Sample size" "p-value" "Bonferroni") ) 

*******************************************************************************
*******************************************************************************
*******************************************************************************

*==============================================================================*
*HOLM
*==============================================================================*
clear
svmat p_values
gen _ = _n
sort p_values1
save "$output/pvals.dta", replace
gen alpha_corr = signif/(hipotesis+1-_n)
gen significant = (p_values1<alpha_corr)
replace significant = 0 if significant[_n-1]==0
sort _
mkmat alpha_corr, matrix(holm)

*==============================================================================*
*BKY
*==============================================================================*
use "$output/pvals.dta", clear
rename p_values1 pval
version 10
set more off
sum pval
local totalpvals = r(N)
gen original_sorting_order = _n
sort pval
gen rank = _n if pval~=.
local qval = 1
gen bky06_qval = 1 if pval~=.
while `qval' > 0 {
	local qval_adj = `qval'/(1+`qval')
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	gen reject_rank1 = reject_temp1*rank
	egen total_rejected1 = max(reject_rank1)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	gen reject_rank2 = reject_temp2*rank
	egen total_rejected2 = max(reject_rank2)
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
sort _
pause off
keep pval bky06_qval
mkmat bky06_qval, matrix(bky)
save "$output/sharpenedqvals.dta", replace
*==============================================================================*
use "$input/measures.dta", clear 
global covs_eva	"male i.eva_fu" 
global covs_ent	"male i.ent_fu"
label var treat "Point Estimate"
label var b_tot_cog1_st "Bayley: Cognitive"
label var b_tot_lr1_st "Bayley: Receptive language"
label var b_tot_le1_st "Bayley: Expressive language"
label var b_tot_mf1_st "Bayley: Fine motor"
label var mac_words1_st "MacArthur: Words the child can say"
label var mac_phrases1_st "MacArthur: Complex phrases the child can say"
label var bates_difficult1_st"ICQ: Difficult (-)"
label var bates_unsociable1_st "ICQ: Unsociable (-)"
label var bates_unstoppable1_st "ICQ: Unstoppable (-)"
label var roth_inhibit1_st "ECBQ: Inhibitory control"
label var roth_attention1_st "ECBQ:: Attentional focusing"
label var fci_play_mat_type1_st "FCI: Number of types of play materials"
label var Npaintbooks1_st "FCI:Number of coloring and drawing books"
label var Nthingsmove1_st "FCI: Number of toys to learn movement" 
label var Ntoysshape1_st "FCI: Number of toys to learn shapes" 
label var Ntoysbought1_st "FCI: Number of shop-bought toys"
label var fci_play_act1_st "FCI: Number of types of play activities in last 3 days"
label var home_stories1_st "FCI: Number of times told a story to child in last 3 days"
label var home_read1_st "FCI: Number of times read to child in last 3 days"
label var home_toys1_st "FCI: Number of times played with toys in last 3 days"
label var home_name1_st "FCI: Number of times named things to child in last 3 days"



*******************************************************************************
scalar i = 1
******************************************************************************* 
* PANEL A (Child's cognitive skills at follow up) 
******************************************************************************* 
eststo clear

local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
foreach y of local bayley{
	local append append 
	if "`y'"=="b_tot_cog" local append replace 
		cap drop V*
		reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
		eststo: test treat = 0
		estadd scalar p_value = r(p)
		estadd scalar corr_p_value = min(1,r(p)*hipotesis)		
		estadd scalar holm_ = holm[i,1]
		estadd scalar bky_ = bky[i,1]
		scalar i = i + 1			
} 

local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)	
	estadd scalar holm_ = holm[i,1]
	estadd scalar bky_ = bky[i,1]			
	scalar i = i + 1	
} 

esttab using "$output/PanelA_bonferroni_holm_bky.rtf", replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel A. Child’s cognitive skills at follow-up") ///
collabels("") nonumbers ///
eqlabels("Point Estimate" "SE") ///
stats(N p_value corr_p_value holm_ bky_, /// 
labels("Sample size" "p-value" "Bonferroni" "Holm" "BKY") ) 


******************************************************************************* 
* PANEL B (Child's socio-emotional skills at follow up) 
******************************************************************************* 
eststo clear
local bates "bates_difficult bates_unsociable bates_unstoppable" 
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)
	estadd scalar holm_ = holm[i,1]
	estadd scalar bky_ = bky[i,1]
	scalar i = i + 1						
} 

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)
	estadd scalar holm_ = holm[i,1]
	estadd scalar bky_ = bky[i,1]
	scalar i = i + 1
} 

esttab using "$output/PanelB_bonferroni_holm_bky.rtf", replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel B. Child’s socio-emotional skills at follow-up") ///
collabels("") nonumbers ///
eqlabels("Point Estimate" "SE") ///
stats(N p_value corr_p_value holm_ bky_, /// 
labels("Sample size" "p-value" "Bonferroni" "Holm" "BKY") ) 

******************************************************************************* 
* PANEL C (Material investments)  
******************************************************************************* 
eststo clear
local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)	
	estadd scalar holm_ = holm[i,1]
	estadd scalar bky_ = bky[i,1]
	scalar i = i + 1
} 

esttab using "$output/PanelC_bonferroni_holm_bky.rtf", replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel C. Material investments at follow-up") ///
collabels("") nonumbers ///
eqlabels("Point Estimate" "SE") ///
stats(N p_value corr_p_value holm_ bky_, /// 
labels("Sample size" "p-value" "Bonferroni" "Holm" "BKY") ) 

******************************************************************************* 
* PANEL D (Time investments)  
******************************************************************************* 
eststo clear
local fcitime "fci_play_act home_stories home_read home_toys home_name"
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hipotesis)
	estadd scalar holm_ = holm[i,1]
	estadd scalar bky_ = bky[i,1]
scalar i = i + 1
}

esttab using "$output/PanelD_bonferroni_holm_bky.rtf", replace label noobs ///
keep(treat, relax) nonumbers  ///
cells( b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel D. Time investments at follow-up") ///
collabels("") ///
eqlabels("Point Estimate" "SE") ///
stats(N p_value corr_p_value holm_ bky_, /// 
labels("Sample size" "p-value" "Bonferroni" "Holm" "BKY") ) 
