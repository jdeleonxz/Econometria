library(readxl)
library(tidyverse)
library(lubridate)
library(ggplot2)
install.packages("forecast")
library(forecast)
library(urca)


setwd("C:/Users/Jorge De León/Desktop/Master/Temas en econometría/Temas")

velocity <- read_xlsx("velocity.xlsx")

#Model 1 - AR(1)

mod1 <- arima(velocity$velocity, order = c(1,0,0), include.mean = FALSE)
mod1

 pp1 <- ur.pp(velocity_ts)
 summary(pp1)

#Model 2 - AR(1) with intercept 

mod2 <- arima(velocity$velocity, order = c(1,0,0), include.mean = TRUE)
mod2
mod4 <- tslm(velocity_ts ~ lag(velocity$velocity, k=1))
summary(mod4)

pp3 <- ur.pp(velocity_ts, mode = "trend")
summary(pp3)

#Model 3 - AR(1) with time trend

velocity_ts <- as.ts(velocity$velocity)
velocity_lags <- c(NA, velocity$velocity[2:92])
mod3 <- tslm(velocity_ts ~ lag(velocity$velocity, k = 1) + trend)
summary(mod3)

help("ur.pp")
