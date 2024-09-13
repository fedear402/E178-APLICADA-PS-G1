/*******************************************************************************
                      Problem Set 4 Anchorena Braga Lopez Musich		
                          Universidad de San Andrés
                              Economía Aplicada
							      					           
*******************************************************************************/



global main ""
global input "$main/input"
global output "$main/output"

cd "$main"

clear all
use "$input/poppy", clear

*==============================================================================*
* 1)
*==============================================================================*
gen chinpres = 0
replace chinpres = 1 if chinos1930hoy >= 1 
// hay presencia si por lo menos tiene un chino
label var chinpres "Chinese presence"

*==============================================================================*
* 2)
*==============================================================================*

drop if estado == "Distrito Federal"

label var Del_RoboVehi2015 "Vehicular theft 2015"
label var Del_RoboNegocio2015 "Shop theft 2015"
label var Del_RoboCasa2015 "House theft 2015"
label var chinos1930hoy "Chinese presence 1930"
label var capestado "State capital"
label var cartel2005 "Cartel presence 2005"
label var cartel2010 "Cartel presence 2010"
label var mindistcosta "Distance to coast"
label var Impuestos_pc_mun "Per capita tax revenue"
label var pob1930cabec "Population in 1930 (in 000)"


su superficie_km distancia_km alturamin alturamax OVSEE_2010 POB_TOT_2015 /// 
ANALF_2015 SPRIM_2015 OVSDE_2015 OVSEE_2015 OVSAE_2015 VHAC_2015 OVPT_2015 /// 
PL5000_2015 PO2SM_2015 IM_2015 TempMed_Anual PrecipAnual_med densidad chinos1930hoy /// 
dalemanes Impuestos_pc_mun pob1930cabec distkmDF capestado suitability tempopium /// 
Del_RoboCasa2015 Del_RoboNegocio2015 Del_RoboVehi2015 ejecuciones cartel2005 cartel2010 /// 
mindistcosta growthperc chinpres

estpost sum superficie_km distancia_km alturamin alturamax OVSEE_2010 POB_TOT_2015 /// 
ANALF_2015 SPRIM_2015 OVSDE_2015 OVSEE_2015 OVSAE_2015 VHAC_2015 OVPT_2015 PL5000_2015 /// 
PO2SM_2015 
IM_2015 TempMed_Anual PrecipAnual_med densidad chinos1930hoy dalemanes /// 
Impuestos_pc_mun pob1930cabec distkmDF capestado suitability tempopium Del_RoboCasa2015  ///  
Del_RoboNegocio2015 Del_RoboVehi2015 ejecuciones cartel2005 cartel2010 mindistcosta  /// 
growthperc chinpres, listwise

esttab using "$output/sum.tex", cells("mean sd min max") numbers /// 
nomtitle collabels("Mean" "SD" "Min" "Max") replace label

*==============================================================================*
* 3)
*==============================================================================*
eststo clear
eststo: reg cartel2010 chinpres id_estado, cluster(id_estado)
eststo: reg cartel2010 chinpres id_estado dalemanes tempopium distancia_km distkmDF  /// 
mindistcosta capestado superficie_km TempMed_Anual PrecipAnual_med pob1930cabec, cluster(id_estado)
eststo: reg cartel2005 chinpres id_estado, cluster(id_estado)
eststo: reg cartel2005 chinpres id_estado dalemanes tempopium distancia_km distkmDF  /// 
mindistcosta capestado superficie_km TempMed_Anual PrecipAnual_med pob1930cabec, cluster(id_estado)
esttab using "$output/ej3-.tex", se replace label noobs ///
keep(chinpres) stats(N clusters, fmt(0 2) labels("Observations" "Controls")) 


*==============================================================================*
* 4)
*==============================================================================*
/*
n Columns (2) to (4) the set of controls includes German presence, Poppy suitability, Average
temperature, Average precipitation, Surface, Population in 1930, Distance to U.S., 
Distance to Mexico City, Distance to closest port, and Head of state. Column (5)
further controls for Local population growth. Column (3) excludes municipalities located 
more than 100 km from U.S. border. Column (4) excludes municipalities
located in the state of Sinaloa. 
*/
eststo clear
eststo: ivregress 2sls IM_2015 (cartel2010=chinpres) id_estado, cluster(id_estado)

eststo: ivregress 2sls IM_2015 (cartel2010=chinpres) id_estado dalemanes tempopium  /// 
distancia_km distkmDF mindistcosta capestado superficie_km TempMed_Anual PrecipAnual_med  /// 
pob1930cabec, cluster(id_estado)

preserve
drop if distancia_km>100
eststo: ivregress 2sls IM_2015 (cartel2010=chinpres) id_estado dalemanes tempopium  /// 
distancia_km distkmDF mindistcosta capestado superficie_km TempMed_Anual  /// 
PrecipAnual_med pob1930cabec, cluster(id_estado)
restore

preserve
drop if municipio == "Sinaloa"
eststo: ivregress 2sls IM_2015 (cartel2010=chinpres) id_estado dalemanes tempopium  /// 
distancia_km distkmDF mindistcosta capestado superficie_km TempMed_Anual  /// 
PrecipAnual_med pob1930cabec, cluster(id_estado)
restore


eststo: ivregress 2sls IM_2015 (cartel2010=chinpres) id_estado dalemanes tempopium  /// 
distancia_km distkmDF mindistcosta capestado superficie_km TempMed_Anual  /// 
PrecipAnual_med pob1930cabec growthperc, cluster(id_estado)

esttab using "$output/ej47.tex", se replace label noobs keep(cartel2010)  /// 
stats(N , fmt(0 2) labels("Number of Observations"))

* 8
eststo clear
eststo: ivregress 2sls ANALF_2015 (cartel2010=chinpres) id_estado  /// 
dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km  /// 
pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

*Without primary:
eststo: ivregress 2sls SPRIM_2015 (cartel2010=chinpres) id_estado  /// 
dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km  /// 
pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

*Without toilet:
eststo: ivregress 2sls OVSDE_2015 (cartel2010=chinpres) id_estado  /// 
dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km  /// 
pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

*Without electricity:
eststo: ivregress 2sls OVSEE_2015 (cartel2010=chinpres) id_estado  /// 
dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km  /// 
pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

*Without water:
eststo: ivregress 2sls OVSAE_2015 (cartel2010=chinpres) id_estado  /// 
dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km  /// 
pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

*Overcrowding:
eststo: ivregress 2sls VHAC_2015 (cartel2010=chinpres) id_estado  /// 
dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km  /// 
pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

*Earthen floor:
eststo: ivregress 2sls OVPT_2015 (cartel2010=chinpres) id_estado  /// 
dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km  /// 
pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

*Small localities:
eststo: ivregress 2sls PL5000_2015 (cartel2010=chinpres) id_estado  /// 
dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km  /// 
pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

*Low salary:
eststo: ivregress 2sls PO2SM_2015 (cartel2010=chinpres) id_estado  /// 
dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km  /// 
pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

esttab using "$output/ej48.tex", se replace label noobs keep(cartel2010) ///
stats(N , fmt(0 2) labels("Number of Observations" "Controls"))

*==============================================================================*
* 5)
*==============================================================================*
eststo clear

*basica
eststo: ivregress 2sls IM_2015 (cartel2010=chinpres) id_estado dalemanes  /// 
tempopium distancia_km distkmDF mindistcosta capestado superficie_km  /// 
TempMed_Anual PrecipAnual_med pob1930cabec

est store iv

reg IM_2015 cartel2010 id_estado dalemanes tempopium distancia_km  /// 
distkmDF mindistcosta capestado superficie_km TempMed_Anual PrecipAnual_med  /// 
pob1930cabec
est store ols

hausman iv ols


