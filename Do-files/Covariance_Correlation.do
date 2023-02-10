clear
set matsize 10000
local SampSize 100
global SampSize `SampSize'
set obs `SampSize'
set seed 12345
gen e = rnormal()

gen y2 = 0
replace y2 = e in 1
replace y2 = 0.4*y2[_n-1] + e in 2/$SampSize

rename y2 yt

generate time = _n
generate ytoffset = yt + 10
generate yttimes = 3*yt
generate yttimesneg = -1.5*yt
generate ytoffneg = -ytoffset

* For an explanation about difference between covariance and correlation:
* https://www.youtube.com/watch?v=KDw3hC2YNFc

twoway (line yt time ) || (line ytoffset time )

correlate yt ytoffset
correlate yt ytoffset, covariance

twoway (line yt time) || (line ytoffneg time )
correlate yt ytoffneg
correlate yt ytoffneg, covariance

twoway (line yt time ) || (line yttimes time )
correlate yt yttimes
correlate yt yttimes, covariance

twoway (line yt time ) || (line yttimesneg time )
correlate yt yttimesneg
correlate yt yttimesneg, covariance


