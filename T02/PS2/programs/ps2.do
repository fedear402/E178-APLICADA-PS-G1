/*******************************************************************************
                          Semana 3: Problem Set 2 

                          Universidad de San Andrés
                              Economía Aplicada
							       2024							           
*******************************************************************************/


* Source: https://www.aeaweb.org/articles?id=10.1257/app.20200204

/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment and globals

1) Regressions

*******************************************************************************/



* 0) Set up environment
*==============================================================================*

gl main "/Users/federicolopez/Library/CloudStorage/OneDrive-Personal/Documents/UDESA/08/APLICADA/TUTORIALES/E178-APLICADA-PS-G1/T02/PS2"
gl input "$main/input"
gl output "$main/output"

* Open data set

use "$input/measures.dta", clear 

* Global with control variables

global covs_eva	"male i.eva_fu" 
global covs_ent	"male i.ent_fu"



* 1) Regressions
*==============================================================================*
/*
foreach y in $psyvars{
	local outcome "`y'1"
	eststo: reg `outcome' treat `y'_full0 `y'_miss0 i.village, cluster(surveyid)
}

esttab using "$output/Table4_.rtf", se replace label noobs ///
keep(treat, relax) ///
cells(b(fmt(2) star) se(par fmt(2))) ///
stats(N r2, fmt(0 2) labels("Number of Observations" "R-Squared"))
*/
******************************************************************************* 
* PANEL A (Child's cognitive skills at follow up) 
******************************************************************************* 

eststo clear

label var b_tot_cog1_st "Bayley: Cognitive"
label var b_tot_lr1_st "Bayley: Receptive language"
label var b_tot_le1_st "Bayley: Expressive language"
label var b_tot_mf1_st "Bayley: Fine motor"
label var mac_words1_st "MacArthur: Words the child can say"
label var mac_phrases1_st "MacArthur: Complex phrases the child can say"
label var treat "Point Estimate"

local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
foreach y of local bayley{
	local append append 
	if "`y'"=="b_tot_cog" local append replace 
		cap drop V*
		eststo: reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
	} 

local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	eststo: reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
} 

esttab using "$output/PanelA.rtf", replace label noobs ///
keep(treat, relax) ///
cells( b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel A. Child’s cognitive skills at follow-up") ///
collabels("") ///
eqlabels("Point Estimate" "SE") ///
stats(N, labels("Sample size") ) 


******************************************************************************* 
* PANEL B (Child's socio-emotional skills at follow up) 
******************************************************************************* 
label var bates_difficult1_st"ICQ: Difficult (-)"
label var bates_unsociablel_st "ICQ: Unsociable (-)"
label var bates_unstoppable1_st "ICQ: Unstoppable (-)"
label var roth_inhibit1_st "ECBQ: Inhibitory control"
label var roth_attention1_st "ECBQ:: Attentional focusing"

local bates "bates_difficult bates_unsociable bates_unstoppable" 
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
} 

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
} 

esttab using "$output/PanelB.rtf", replace label noobs ///
keep(treat, relax) ///
cells( b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel A. Child’s cognitive skills at follow-up") ///
collabels("") ///
eqlabels("Point Estimate" "SE") ///
stats(N, labels("Sample size") ) 

******************************************************************************* 
* PANEL C (Material investments)  
******************************************************************************* 

label var fci_play_mat_typel_st "FCI: Number of types of play materials"
label var Npaintbooks1_st "FCI:Number of coloring and drawing books"
label var Nthingsmove1_st "FCI: Number of toys to learn movement" 
label var Ntoysshapel_st "FCI: Number of toys to learn shapes" 
label var Ntoysbought1_st "FCI: Number of shop-bought toys"

local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
} 

esttab using "$output/PanelC.rtf", replace label noobs ///
keep(treat, relax) ///
cells( b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel A. Child’s cognitive skills at follow-up") ///
collabels("") ///
eqlabels("Point Estimate" "SE") ///
stats(N, labels("Sample size") ) 

******************************************************************************* 
* PANEL D (Time investments)  
******************************************************************************* 

label var fci_play_act1_st "FCI: Number of types of play activities in last 3 days"
label var home_stories1_st "FCI: Number of times told a story to child in last 3 days"
label var home_read1_st "FCI: Number of times read to child in last 3 days"
label var home_toys1_st "FCI: Number of times played with toys in last 3 days"
label var home_name1_st "FCI: Number of times named things to child in last 3 days"

local fcitime "fci_play_act home_stories home_read home_toys home_name"
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
} 

esttab using "$output/PanelD.rtf", replace label noobs ///
keep(treat, relax) ///
cells( b(fmt(3)) t(drop(treat)) se(par label(SE) fmt(3)) ) /// 
title("Panel A. Child’s cognitive skills at follow-up") ///
collabels("") ///
eqlabels("Point Estimate" "SE") ///
stats(N, labels("Sample size") ) 

