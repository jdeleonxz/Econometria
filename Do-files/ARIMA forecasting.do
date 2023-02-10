clear all

use http://www.stata-press.com/data/r16/wpi1.dta

tsset t, quarterly

twoway line wpi t
twoway line ln_wpi t

ac ln_wpi

ac d.ln_wpi

pac d.ln_wpi

arima D.ln_wpi, ar(1) ma(1 4)
predict res, residuals

ac res
pac res

* ------------------------------------------------------------------------------------

arima D.ln_wpi if tin(, 1984q4), ar(1) ma(1 4)
* one-step-ahead (osa)
predict fcast_one, xb
predict fcast_onemse, mse
gen fcast_oneup = fcast_one + 1.96*sqrt(fcast_onemse)
gen fcast_onedn = fcast_one - 1.96*sqrt(fcast_onemse)

twoway rarea fcast_oneup fcast_onedn t, ///
lcolor(gs14) fcolor(gray) fintensity(25) lcolor(white) || ///
line D.ln_wpi fcast_one t, lcolor(blue red)

drop fcast*


* dynamic forecast (switching from observed values of D.ln_wpi to forecasted values after 1984q4)
arima D.ln_wpi if tin(, 1984q4), ar(1) ma(1 4)
predict fcast_dyn, dynamic(tq(1984q4)) xb
predict fcast_dynmse, dynamic(tq(1984q4)) mse
gen fcast_dynup = fcast_dyn + 1.96*sqrt(fcast_dynmse)
gen fcast_dyndn = fcast_dyn - 1.96*sqrt(fcast_dynmse)

twoway rarea fcast_dynup fcast_dyndn t, ///
lcolor(gs14) fcolor(gray) fintensity(25) lcolor(white) || ///
line D.ln_wpi fcast_dyn t, lcolor(blue red)


twoway line D.ln_wpi fcast_one fcast_dyn t, lcolor(blue red green)


* Use option "y" to forecast the level of the variable; in this case ln_wpi
arima D.ln_wpi if tin(, 1984q4), ar(1) ma(1 4)
* one-step-ahead (osa)
predict fcast_one, y
