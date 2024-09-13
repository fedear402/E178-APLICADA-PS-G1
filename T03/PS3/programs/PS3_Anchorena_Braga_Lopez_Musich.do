/*******************************************************************************
                          Semana 3: Problem Set 2 

                          Universidad de San Andrés
                              Economía Aplicada
							         2024			
						Integrantes: Federico Ariel Lopez
									 Rodrigo Braga
									 Joaquin Musich
									 Ignacio Anchorena
*******************************************************************************/
clear all
gl main "/Users/ignacioanchorena/Desktop/Eco Aplicada/PS3" // No vamos a usar ninguna base de datos para esta parte del trabajo

gl input "$main/input"
gl output "$main/output"

clear

set obs 100 
set seed 1233 // seteamos la semilla asi las 100 obs son siempre iguales

*Ahora genero las variables que voy a usar para la parte 1 del problem set 

gen intelligence=int(rnormal(100,20)) // Primero la variable intelligence

gen education=int(intelligence/10+rnormal(0,1)) // Depues ponemos la variable education que va a depender de intelligence

gen w=int(rnormal(10,3)) // Generamos una variable que se llama w

gen z=int(rnormal(5,1)) // Generamos una variable que se llama z

gen u=int(rnormal(7,1)) // Por último, generamos la variable u que será el termino error

gen wage=3*intelligence+w+2*z+u // Wage va a ser nuestar variable explicada

* Ahora corremos una regresion con wage como variable dependiente de w y z para guardar y comparar con los futuros resultados

reg wage intelligence w z 
predict wage_hat_1 // Guardamos wage estiamdo
est store ols1

////// Inciso 1 //////

//Para este inciso vamos a hacer lo mismo que antes pero esta vez con el doble de observaciones. Para esto vamos a utilizar la misma seed y las variables estarán conformadas como antes. Corremos la misma regresión y vemos las diferencias en los desviós estandar

clear
set obs 200
set seed 1233

gen intelligence=int(rnormal(100,20))
gen education=int(intelligence/10+rnormal(0,1))
corr education intelligence

gen w=int(rnormal(10,3))
gen z=int(rnormal(5,1))
gen u=int(rnormal(7,1))
gen wage=3*intelligence+w+2*z+u

reg wage intelligence w z
predict y_hat_2
est store ols2

esttab ols1 ols2 using "$output/Tabla1.rtf", se replace

////// Inciso 2 //////

// Para este inciso vamos a contruir la mismsa regresion que al principio pero a la variable "u" le vamos a aumentar su varianza.
clear
set obs 100
set seed 1233

gen intelligence=int(rnormal(100,20))
gen education=int(intelligence/10+rnormal(0,1))
corr education intelligence

gen w=int(rnormal(10,3))
gen z=int(rnormal(5,1))
gen u=int(rnormal(7,7))
gen wage=3*intelligence+w+2*z+u

reg wage intelligence w z
predict mu_hat, residuals // Guardamos los residuos
generate sumatoria_mu_hat = round(sum(mu_hat),0)

est store ols3

esttab ols1 ols3 using "$output/Tabla2.rtf", se replace

////// Inciso 3 //////

// Para este inciso vamos a contruir la misma regresion que al principio pero a la variable intelligence la vamos a multiplicar por 40 en vez de 20 para aumentar su varianza

clear
set obs 100
set seed 1233
gen intelligence=int(rnormal(100,40)) 
gen education=int(intelligence/10+rnormal(0,1))
corr education intelligence

gen w=int(rnormal(10,3))
gen z=int(rnormal(5,1))
gen u=int(rnormal(7,1))

gen wage=3*intelligence+w+2*z+u
reg wage intelligence w z
predict y_hat_3

est store ols4

esttab ols1 ols4 using "$output/Tabla3.rtf", se replace

////// Inciso 4 //////

// Usando el modelo del inciso 3, calculamos los residuos
predict residuos, residuals
total residuos

////// Inciso 5 //////

// Para saber si los residuos son ortogonales a los regresores, corremos una regresión entre los residuos y los regresores. Si fuesen ortogonales, la correlación debería dar cero.

reg residuos intelligence w z
est store ols5

esttab ols5 using "$output/Tabla5.rtf", se replace


////// Inciso 6 //////
clear

set obs 100 
set seed 1233 

gen intelligence=int(rnormal(100,20)) 
gen education=int(intelligence/10+rnormal(0,1))
gen w=int(rnormal(10,3)) 
gen z=int(rnormal(5,1))
gen u=int(rnormal(7,1))
gen wage=3*intelligence+w+2*z+u


reg wage intelligence w z 
predict wage_hat_1 
est store ols1

reg wage education intelligence w z
predict y_hat_6
est store ols6
esttab ols1 ols6 using "$output/Tabla6.rtf", se replace
 
////// Inciso 7 //////

// Vamos a generar una variable donde tenga error aleatorio y otra donde el error esté en un dato en especifico.

gen intelligence_al_err = intelligence+int(invnormal(uniform())*1+1) // variable con error aleatorio

gen intelligence_esp_err = intelligence+0.9 // Variable con error especifico

eststo: reg wage intelligence w z
eststo: reg wage intelligence_al_err w z
eststo: reg wage intelligence_esp_err w z

esttab using "$output/Tabla7.rtf", se replace

eststo clear
////// Inciso 8 //////

// Ahora el problema va a estar en la variable Y, el salario. Vamos a usar el mismo procedimiento que el inciso 7, pero vamos a correr la regresión con la variable intelligence correcta.

gen wage_al_err=wage+int(invnormal(uniform())*1+1)

gen wage_esp_err=wage+0.9

eststo: reg wage intelligence w z
eststo: reg wage_al_err intelligence w z
eststo: reg wage_esp_err intelligence w z

esttab using "$output/Tabla8.rtf", se replace

