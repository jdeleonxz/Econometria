
*Source : https://blog.stata.com/2015/10/06/monte-carlo-simulations-using-stata/

/*
To run Stata if you are in the classroom use:
\\srvlicencias01\Stata15

Or, if you are at home:
https://urosario.edu.co/PortalUrosario/media/UR-V4/Clases-de-acceso-remoto/img/Manual-Ingreso-stata.pdf
*/

/*Declare a global with path of current directory*/

global RunPath "c:\Renzo\OneDrive - Universidad del rosario\PhD\2023-i\ContractActivities\Jesus\Monitorias\ene\27\Stata"
global OutPath "$RunPath/Output"
cd "$RunPath"

local a 1
display "Example of the value of local ""a"": `a'"

display "Example of the value of global RunPath: $RunPath"

*************************************************************
/*1. Create random draws and compute the mean of these draws*/
*************************************************************

clear
drop _all
set obs 5000000
set seed 12345 // Try without seed and check the changes
generate y = rchi2(1) // rchi2( degrees of freedom). Theoretically, the mean of the distribution equals the degrees of freedom.
mean y
return list
matrix list r(table)
egen ymean = mean(y)
egen ysd = sd(y)
generate yse = ysd / sqrt(_N) // This is the standard error (how far mhat is from the true average value)
kdensity y


*************************************************************
/*2. Create random draws, compute the mean of these draws
and repeat the process a specified number of times  */
*************************************************************

clear
drop _all
set seed 12345
postutil clear
postfile buffer mhat using "$OutPath/mcs", replace
forvalues i=1/2000 {
	quietly drop _all
	quietly set obs 500
	*quietly generate y = rchi2(1)
	quietly generate y = runiform(1,2) // runiform(lower bound, upper bound)
	quietly mean y
	post buffer (_b[y])
}
postclose buffer
use "$OutPath/mcs", clear
kdensity mhat
graph export "$OutPath/MC2000rep.pdf", as(pdf) replace


*************************************************************
/*3. Create random draws, compute the mean and s.d. of these
draws and repeat the process a specified number of times  */
*************************************************************

clear
set seed 12345
postutil clear
postfile buffer mhat sehat using "$OutPath/mcs", replace
forvalues i=1/20000 {
	quietly drop _all
	quietly set obs 500
	quietly generate y = rchi2(1) // rchi2(degrees of freedom)
	*quietly generate y = runiform(1,2)
	quietly mean y
	post buffer (_b[y]) (_se[y])
}
postclose buffer
use "$OutPath/mcs", clear
sum mhat sehat

/*
The sample variance of a Chi Square RV:
sigma^2 = 2*k/n. Compare against se reported by Stata.
Use n = 500 and compute: sqrt(2*1/500)
*/

kdensity mhat
/*
Why the distribution of the mean resembles a normal distribution?
*/

/*
Recall the Cetral Limit Theorem
See https://ocw.mit.edu/courses/mathematics/18-05-introduction-to-probability-and-statistics-spring-2014/readings/MIT18_05S14_Reading6b.pdf
*/


*************************************************************
/*4. Create random draws, compute the mean and s.d. of these
draws, repeat the process a specified number of times, and
estimate a rejection rate.*/
*************************************************************


clear
set seed 12345
postutil clear
postfile buffer mhat sehat W_value reject using "$OutPath/mcs", replace
forvalues i=1/2000 {
	quietly drop _all
	quietly set obs 500 // Try different amount of observations and see what happens with rejection ratio.
	quietly generate y = rchi2(1) // rchi2( degrees of freedom)
	*quietly generate y = runiform(1,2)
	quietly mean y
	quietly test _b[y] = 1 // The command "test" is a Wald test to establish if the mean is equal to 1.
	local r = (r(p) < 0.05)
	local variance = (_se[y]*sqrt(_N))^2
	local W_value = ((_b[y] - 1)/(`variance'))*(_b[y] - 1)*_N // This statistic is distributed Chi Square with 1 degree of freedom
	// W = (b - a)*inv(\hat{var}(b))*(b - a); var(b) = (se(b))^2, because this is an estimator of the variance for the parameter, not just the variance of the sample
	post buffer (_b[y]) (_se[y]) (`W_value') (`r')
}
postclose buffer
use "$OutPath/mcs", clear
summarize



*************************************************************
/*5. Create a regression with normal errors and compute the 
the estimated coefficients with OLS*/
*************************************************************

clear
set seed 12345
set obs 500
gen x = _n
local beta0 = 5
gen e = rnormal(0,100)
gen y = x*`beta0' + e
scatter y x
regress y x
return list
mat list r(table)

*************************************************************
/*6. Create a regression with normal errors and compute the 
the estimated coeffcients with OLS. Repeat the process a
specified number of times.*/
*************************************************************

clear
set seed 12345
postutil clear
postfile buffer beta betase using "$OutPath/OLS", replace
forvalues i=1/2000 {
	quietly{
		drop _all
		set obs 500
		gen x = _n
		local beta0 = 5
		gen e = rnormal(0,100)
		gen y = x*`beta0' + e
		regress y x
		post buffer (_b[x]) (_se[x])
	}
}
postclose buffer
use "$OutPath/OLS", clear
kdensity beta
summarize

