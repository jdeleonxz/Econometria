
global RunPath "c:\Renzo\OneDrive - Universidad del rosario\PhD\2023-i\ContractActivities\Jesus\Monitorias\feb\03\Stata"
cd "$RunPath"

/*Create an AR model */

clear
set matsize 10000
local SampSize 2000
global SampSize `SampSize'
set obs `SampSize'
set seed 123
gen e = rnormal()
gen y = 0
gen y1 = 0
mkmat y1, matrix(y1mat)
mkmat e, matrix(emat)
forvalues i = 2/`SampSize'{
	mat temp = 0.5*y1mat[`i'-1,1] + emat[`i',1] // Try positive and negative values
	mat y1mat[`i',1] = temp
}
drop y1
svmat double y1mat, names(y)
rename y1 yt
generate yt1 = yt[_n - 1]
generate time = _n
tsset time
keep time yt yt1 e
order time


generate yt2 = L2.yt
generate yt3 = L3.yt
generate yt4 = L4.yt
generate yt5 = L5.yt


ac yt, lags(15) generate(acvar)
corr yt yt1
corr yt yt2
corr yt yt3
corr yt yt5


pac yt, lags(15) generate(pacvar)
reg yt yt1 
* The coefficient on yt1 shows partial autocorrelation between yt and y_{t-1}
reg yt yt1 yt2 
* The coefficient on yt2 shows partial autocorrelation between yt and y_{t-2}
reg yt yt1 yt2 yt3 
* The coefficient on yt3 shows partial autocorrelation between yt and y_{t-3}
reg yt yt1 yt2 yt3 yt4
* The coefficient on yt4 shows partial autocorrelation between yt and y_{t-4}
reg yt yt1 yt2 yt3 yt4 yt5
* The coefficient on yt5 shows partial autocorrelation between yt and y_{t-5}



generate y2 = 0 in 1/7
replace y2 = 0.9*y2[_n - 7] + e in 8/$SampSize
ac y2
pac y2




reg yt yt1, nocons // Perform a linear regression to compare predictions
*arima yt , ar(1 4) nocons 
arima yt , ar(1) nocons

tsappend, add(5) // Add one observation to the database to perform forecasting
*list yt time in 1 / L
predict ythat // Compare these predictions with information at file ar.xlsx



/*Create a moving average model MA(1)*/
clear
local SampSize 200
global SampSize `SampSize'
set obs `SampSize'
set seed 123
gen e = rnormal()
gen y = 0
gen y1 = 0
mkmat y1, matrix(y1mat)
mkmat e, matrix(emat)
forvalues i = 2/`SampSize'{
	mat temp = emat[`i',1] + 0.4*emat[`i'-1,1] // Try positive and negative values
	mat y1mat[`i',1] = temp
}
drop y1
svmat double y1mat, names(y)
rename y1 yt
generate yt1 = yt[_n - 1]
generate time = _n
tsset time
keep time yt yt1
order time
reg yt yt1, nocons
*arima yt , ar(1/2) nocons 
arima yt , ma(1) nocons
predict ythat
format yt yt1 ythat %20.0g

predict r, residuals

tsappend , add(1)

drop ythat

predict ythat

format ythat r %20.0g


/*Dataset with daily electricity prices in USA*/

clear
use http://www.stata-press.com/data/eeus/lwp
generate llwp = log(lwp)
line llwp date
ac llwp
pac llwp

reg llwp L(1/7).llwp
scalar AICVal = ln(e(rss)/e(N)) + 2*e(df_m)/e(N)
display "AIC by hand: " AICVal
scalar SICVal = ln(e(rss)/e(N)) + e(df_m)/e(N)*ln(e(N))
display "SIC by hand: " SICVal

arima llwp , ar(1/7)
estat ic


