cd "d:\JESUS\Jgo\Econometria - Maestria\Bases de Datos"

clear all
set seed 12345

local draws 10000
local obs 500

postfile buffer bhat`obs' using mcs`obs', replace

forvalues i=1/`draws' {
quietly drop _all
quietly set obs `obs'
quietly generate t = _n
quietly tsset t
quietly generate u = rnormal()
quietly generate y = 0
quietly replace y = 0.5*l.y + u in 2/`obs'
quietly reg y l.y
post buffer (_b[l.y])
}

postclose buffer

use mcs`obs', clear


use mcs20, clear
merge 1:1 _n using mcs50
drop _merge

merge 1:1 _n using mcs100
drop _merge

merge 1:1 _n using mcs200
drop _merge

merge 1:1 _n using mcs500
drop _merge

su bhat20 bhat50 bhat100 bhat200 bhat500

twoway (histogram bhat20, color(red%30)) ///
       (histogram bhat100, color(blue%30)) ///
       (histogram bhat500, color(green%30)), ///
       legend(order(1 "T=20" 2 "T=100" 3 "T=500") nobox size(small) region(lstyle(none)) col(3)) ///
	   graphregion(color(white)) ///
	   xtitle("", size(medium)) ///
       xlabel(, format(%9.1f) labsize(medium)) ///
       ytitle("Density", size(medium)) ///
       ylabel(, angle(0) format(%9.0f) labsize(medium))
       graph export fig_bias_ar1.eps, replace

	   
	   
* Simulation for cross section data


clear all
set seed 12345

local draws 10000
local obs 100

postfile buffer tstat`obs' using mcs`obs', replace

forvalues i=1/`draws' {
quietly drop _all
quietly set obs `obs'
quietly generate t = _n
quietly tsset t
quietly generate u = rnormal()
quietly generate x = rnormal()
quietly generate y = rnormal()
quietly replace y = x + u in 2/`obs'
quietly reg y x
post buffer ((_b[x]-1)/_se[x])
}

postclose buffer

use mcs`obs', clear

su tstat100

twoway (kdensity tstat100, color(blue)) ///
       (function y=tden(20,x), range(-4 4)), ///
       legend(order(1 "Empirical distribution" 2 "Student-{it: t} distribution") nobox size(small) region(lstyle(none)) col(3)) ///
	   graphregion(color(white)) ///
	   xtitle("", size(medium)) ///
       xlabel(, format(%9.0f) labsize(medium)) ///
       ytitle("Density", size(medium)) ///
       ylabel(, angle(0) format(%9.1f) labsize(medium))
       graph export fig_ttest_xsection.eps, replace
	   
	   
* Simulation for random walk


clear all
set seed 12345

local draws 10000
local obs 100

postfile buffer tstat`obs' using mcs`obs', replace

forvalues i=1/`draws' {
quietly drop _all
quietly set obs `obs'
quietly generate t = _n
quietly tsset t

quietly generate u = rnormal()
quietly generate y = 0
quietly replace y = l.y + u in 2/`obs'

quietly reg y l.y, noconstant
*quietly reg y l.y
*quietly reg y l.y t
post buffer ((_b[l.y]-1)/_se[l.y])
}

postclose buffer

use mcs`obs', clear

su tstat100, detail



twoway (kdensity tstat100, color(blue)) ///
       (function y=tden(20,x), range(-4 4)), ///
       legend(order(1 "Empirical distribution" 2 "Student-{it: t} distribution") nobox size(small) region(lstyle(none)) col(3)) ///
	   graphregion(color(white)) ///
	   xtitle("", size(medium)) ///
       xlabel(, format(%9.0f) labsize(medium)) ///
       ytitle("Density", size(medium)) ///
       ylabel(, angle(0) format(%9.1f) labsize(medium))
       graph export fig_ttest_rwalk.eps, replace


* Spurious regression	   



clear all
set seed 12345

local draws 10000
local obs 100

postfile buffer tstat`obs' using mcs`obs', replace

forvalues i=1/`draws' {
quietly drop _all
quietly set obs `obs'
quietly generate t = _n
quietly tsset t

quietly generate u = rnormal()
quietly generate v = rnormal()

quietly generate y = 0
quietly replace  y = l.y + u in 2/`obs'

quietly generate x = 0
quietly replace  x = l.x + v in 2/`obs'

quietly reg y x
post buffer (_b[x]/_se[x])
}

postclose buffer

use mcs`obs', clear

gen indic = abs(tstat100)>1.96 

su indic, detail



twoway (kdensity tstat100, color(blue)) ///
       (function y=tden(20,x), range(-4 4)), ///
       legend(order(1 "Empirical distribution" 2 "Student-{it: t} distribution") nobox size(small) region(lstyle(none)) col(3)) ///
	   graphregion(color(white)) ///
	   xtitle("", size(medium)) ///
       xlabel(, format(%9.0f) labsize(medium)) ///
       ytitle("Density", size(medium)) ///
       ylabel(, angle(0) format(%9.1f) labsize(medium))
       graph export fig_spurious_reg.eps, replace


	   


clear all
set seed 12345

local draws 10000
local obs 100

postfile buffer tstat`obs' using mcs`obs', replace

forvalues i=1/`draws' {
quietly drop _all
quietly set obs `obs'
quietly generate t = _n
quietly tsset t

quietly generate u = rnormal()
quietly generate v = rnormal()

quietly generate y = 0
quietly replace  y = l.y + u in 2/`obs'

quietly generate x = 0
quietly replace  x = l.x + v in 2/`obs'

quietly reg D.y D.x
post buffer (_b[D.x]/_se[D.x])
}

postclose buffer

use mcs`obs', clear

gen indic = abs(tstat100)>1.96 

su indic, detail



twoway (kdensity tstat100, color(blue)) ///
       (function y=tden(20,x), range(-4 4)), ///
       legend(order(1 "Empirical distribution" 2 "Student-{it: t} distribution") nobox size(small) region(lstyle(none)) col(3)) ///
	   graphregion(color(white)) ///
	   xtitle("", size(medium)) ///
       xlabel(, format(%9.0f) labsize(medium)) ///
       ytitle("Density", size(medium)) ///
       ylabel(, angle(0) format(%9.1f) labsize(medium))
       graph export fig_stationary_case.eps, replace
	   
	   	   
		   
		   
* Simultaneous equations plots
clear all
set seed 12345


set obs 500

quietly generate x = runiform(2, 8)
quietly generate y = runiform(2, 8)


graph twoway (scatter y x, msize(*.1)), ///
	   graphregion(color(white)) ///
	   xtitle("Quantity", size(medium)) ///
       xlabel("", format(%9.0f) labsize(medium)) ///
       ylabel("", angle(0) format(%9.0f) labsize(medium)) ///
	   ytitle("Price")
       graph export fig_supply_demand_1.eps, replace


graph twoway (scatter y x, msize(*.1)) ///
    (function y = 8 - 0.5*x, range(1 9)), ///
    legend(off nobox size(small) region(lstyle(none)) col(3)) ///
	graphregion(color(white)) ///
	xtitle("Quantity", size(medium)) ///
    xlabel("", format(%9.0f) labsize(medium)) ///
    ylabel("", angle(0) format(%9.0f) labsize(medium)) ///
	ytitle("Price")
    graph export fig_supply_demand_2.eps, replace   
	   

graph twoway (scatter y x, msize(*.1)) ///
    (function y = 2 + 0.5*x, range(1 9)), ///
    legend(off nobox size(small) region(lstyle(none)) col(3)) ///
	graphregion(color(white)) ///
	xtitle("Quantity", size(medium)) ///
    xlabel("", format(%9.0f) labsize(medium)) ///
    ylabel("", angle(0) format(%9.0f) labsize(medium)) ///
	ytitle("Price")
    graph export fig_supply_demand_3.eps, replace   
  
	   
graph twoway /*(scatter y x, msize(*.1))*/ ///
    (function y = 2 + 0.5*x  , lcolor(red)  lwidth(*.5) range(1 9)) ///
	(function y = 6.4 - 0.5*x, lcolor(blue) lwidth(*.25) range(1 9)) ///
	(function y = 6.8 - 0.5*x, lcolor(blue) lwidth(*.25) range(1 9)) ///
	(function y = 7.2 - 0.5*x, lcolor(blue) lwidth(*.25) range(1 9)) ///
	(function y = 7.6 - 0.5*x, lcolor(blue) lwidth(*.25) range(1 9)) ///
    (function y = 8.0 - 0.5*x, lcolor(blue) lwidth(*.25) range(1 9)), ///
    legend(order(2 "Supply curve when Y changes in the demand curve") nobox size(small) region(lstyle(none)) col(3)) ///
	graphregion(color(white)) ///
	xtitle("Quantity", size(medium)) ///
    xlabel("", format(%9.0f) labsize(medium)) ///
    ylabel("", angle(0) format(%9.0f) labsize(medium)) ///
	ytitle("Price")
    graph export fig_supply_demand_4.eps, replace
  
  
graph twoway /*(scatter y x, msize(*.1))*/ ///
    (function y = 8 - 0.5*x,   lcolor(red)  lwidth(*.5) range(1 9)) ///
    (function y = 2.0 + 0.5*x, lcolor(blue) lwidth(*.25) range(1 9)) ///
	(function y = 2.8 + 0.5*x, lcolor(blue) lwidth(*.25) range(1 9)) ///
	(function y = 3.6 + 0.5*x, lcolor(blue) lwidth(*.25) range(1 9)) ///
    (function y = 4.4 + 0.5*x, lcolor(blue) lwidth(*.25) range(1 9)), ///
    legend(order(2 "Demand curve when W changes in the supply curve") nobox size(small) region(lstyle(none)) col(4)) ///
	graphregion(color(white)) ///
	xtitle("Quantity", size(medium)) ///
    xlabel("", format(%9.0f) labsize(medium)) ///
    ylabel("", angle(0) format(%9.0f) labsize(medium)) ///
	ytitle("Price")
	graph export fig_supply_demand_5.eps, replace

	   
  
graph twoway /*(scatter y x, msize(*.25))*/ ///
    (function y = 6.6 - 0.5*x, lcolor(red)  lwidth(*.5) range(1 9)) ///
	(function y = 7.2 - 0.5*x, lcolor(red)  lwidth(*.5) range(1 9)) ///
	(function y = 7.8 - 0.5*x, lcolor(red)  lwidth(*.5) range(1 9)) ///
    (function y = 8.4 - 0.5*x, lcolor(red)  lwidth(*.5) range(1 9)) ///
    (function y = 2 + 0.5*x,   lcolor(blue) lwidth(*.5) range(1 9)) ///
	(function y = 2.6 + 0.5*x, lcolor(blue) lwidth(*.5) range(1 9)) ///
	(function y = 3.2 + 0.5*x, lcolor(blue) lwidth(*.5) range(1 9)) ///
    (function y = 3.8 + 0.5*x, lcolor(blue) lwidth(*.5) range(1 9)), ///
    legend(order(2 "Demand and supply curves when both Y and W change") nobox size(small) region(lstyle(none)) col(4)) ///
	graphregion(color(white)) ///
	xtitle("Quantity", size(medium)) ///
    xlabel(, format(%9.0f) labsize(medium)) ///
    ylabel(, angle(0) format(%9.0f) labsize(medium)) ///
	ytitle("Price")
    graph export fig_supply_demand_6.eps, replace
	   
	   
	   
	   
	   

* Nickell bias	   
* This follows Hurn et al. (2021, p.335)	   
	   
cd "d:\JESUS\Jgo\Econometria - Maestria\Bases de Datos"

clear all
set seed 12345

local rho = 0.2
local beta = 0.8
local gamma = 0.5
local sigma2 = 1
local sigma2s = 2

local bracket = 1 + ((((`gamma'+`rho')^2)/(1+`rho'*`gamma'))*((`rho'*`gamma')-1)) - (`rho'*`gamma')^2

local sigma2e = (`sigma2s' - ((`rho'^2/(1-`gamma'*`rho'^2))*`gamma'^2))*(`bracket'/`beta'^2)

display `sigma2e'

local draws = 1000

forvalues n = 20 100 to 100 {
    forvalues T = 10(10)30 {

		postfile buffer /*
		*/ rhat using nickell_T`T'_n`n', replace

		forvalues draw=1/`draws' {
			quietly {
			drop _all
	
			set obs `T'
	
			gen t= _n
			tsset t
	
			forvalues i=1/`n' {
				gen e`i' = rnormal(0,`sigma2e')
				gen x`i' = 0
				gen y`i' = 0
				gen u`i' = rnormal(0,`sigma2')
			}
	
			forvalues i=1/`n' {
				replace x`i' = `gamma'*l.x`i' + e`i' if t>1
				replace y`i' = `beta'*x`i' + `rho'*l.y`i' + u`i' if t>1
			}

			keep t y* x*
			reshape long y x, i(t) j(n)
			xtset n t
			
			xtreg y l.y x, fe
			post buffer (_b[l.y])
			}
		}

postclose buffer

qui use nickell_T`T'_n`n', clear

qui sum rhat
display "rho= " `rho' " N= " `n' " T= " `T' " rhohat (mean)= " r(mean) " std.dev.= " r(sd)
}

}

	   
// Finite sample properties of ML estimators (LPM, Logit, probit)
// Replicates Table 21.3 in Martin, Hurn, Harris (2013)


cd "d:\JESUS\Jgo\Econometria - Maestria\Bases de Datos"

clear all
set seed 12345

local beta0 = 1
local beta1 = 1
local sigma2 = 1

local draws = 5000

forvalues T = 100/100 {

		postfile buffer /*
		*/ b1_ols b1_lpm b1_probit b1_trunc b1_cens b1_restrict using MLbias_T`T', replace

		forvalues draw=1/`draws' {
			quietly {
			drop _all
	
			set obs `T'
	
			gen t= _n
			tsset t
			
			gen u = rnormal(0,`sigma2')
			gen x = rnormal(0,1)
			gen ystar = `beta0' + `beta1'*x + u
						
			// Linear model
			reg ystar x
			local b1_ols = _b[x]
			
			// Linear probability model
			gen y = ystar>0
			reg y x
			local b1_lpm = _b[x]
			
			// Probit
			probit y x
			local b1_probit = _b[x]

			// Truncated
			gen ytrunc = (ystar>0)*ystar
			replace ytrunc = . if ystar<=0
			truncreg ytrunc x, ll(0)
			local b1_trunc = _b[x]

			// Censored
			gen ycens = (ystar>0)*ystar
			replace ycens = 0 if ystar<=0
			tobit ycens x, ll(0)
			local b1_cens = _b[x]

			// Restricted
			gen yrestrict = (ystar>0)*ystar
			replace yrestrict = 0 if ystar<=0
			regress yrestrict x if yrestrict>0
			local b1_restrict = _b[x]

			post buffer (`b1_ols') (`b1_lpm') (`b1_probit') (`b1_trunc') (`b1_cens') (`b1_restrict')
			
			}
		}

postclose buffer

qui use MLbias_T`T', clear

sum b1_ols b1_lpm b1_probit b1_trunc b1_cens b1_restrict
}



	   
// Finite sample properties of truncated and censored regressions
// Based on DGP in Franses & Paap


cd "d:\JESUS\Jgo\Econometria - Maestria\Bases de Datos"

clear all
set seed 123

local beta0 = -2
local beta1 = 1
local sigma2 = 1

set obs 1000


gen t= _n
tsset t
			
gen u = rnormal(0,`sigma2')
gen x = 0.0001*t  + rnormal(0,1)
gen y = `beta0' + `beta1'*x + u

gen ytrunc = (y>0)*y
replace ytrunc = . if y<=0

gen ycens = (y>0)*y
replace ycens = 0 if y<=0

// Linear model for truncated data
reg ytrunc x

// Truncated regression
truncreg ytrunc x, ll(0)

// Linear model for censored data
reg ycens x

// Censored regression
tobit ycens x, ll(0)



