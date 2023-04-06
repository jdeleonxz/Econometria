*** PARCIAL TEMAS EN ECONOMETRÍA 
*** Jorge De León 

clear all
cd "C:\Users\Jorge De León\Desktop\Master\Temas en econometría\Temas\Parcial 1"

use "dataset_4.dta"

tsset date 

*** gráfico de las 4 series de tiempo
tsline us ca mx no, title("Series de tiempo de los precios") ytitle("Valores") legend(label(1 "US") label(2 "CA") label(3 "MX") label(4 "NO"))

*** Autocorrelación y gráfico de autocorrelaciones

gen diff_us = D.us
gen diff_ca = D.ca
gen diff_mx = D.mx
gen diff_no = D.no

*** Gráficos
*** US
ac us
tsline diff_us, title("Time Series of First Difference US")

*** Gráficos
*** CA
ac ca
tsline diff_ca, title("Time Series of First Difference CA")

*** Gráficos
*** MX
ac mx
tsline diff_mx, title("Time Series of First Difference mx")

*** Gráficos
*** NO
ac no
tsline diff_no, title("Time Series of First Difference NO")

*** PUNTO 3. DICKEY FULLER TEST Y LEYBOURNE TEST

*** Prueba de Dickey Fuller aumentada con lags seleccionados bajo el criterio AIC

dfuller us, trend
dfuller ca, trend
dfuller mx, trend
dfuller no, trend

dfuller diff_us, trend
dfuller diff_ca, trend
dfuller diff_mx, trend
dfuller diff_no, trend

*** Prueba de Leybourne fixed 20 lags
adfmaxur us, trend
adfmaxur ca, trend
adfmaxur mx, trend
adfmaxur no, trend

*** Modelo VAR

*** Estimammos el VAR(4)
var us ca mx no, lags(1/4)


*** Argumentar

*** Determinar el modelo más adecuado

varsoc us ca mx no, maxlag(20)
var us ca mx no, lags(1/3) exog(l4.us l4.ca l4.mx l4.no)

vargranger



*Nos dice que bajo el criterio AIC el número optimo de lags para el modelo var es 10. 

* Argumentar

*** Estimar VEC 
 vecrank us ca mx no, lag(3)
 vec us ca mx no, lag(3) rank(3) trend(rc)


 **** Panel 
 
 clear all
 
 cd "C:\Users\Jorge De León\Desktop\Master\Temas en econometría\Temas\Parcial 1"

use "dataset_4.dta"

foreach var of varlist us ca mx no {
    rename `var' price`var'
}

reshape long price, i(date) j(id_var, string)
encode id_var, gen(pais)
drop id_var
xtset pais date 

xtunitroot ips price, lags(3)
