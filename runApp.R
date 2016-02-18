# title   : 2015資料科學與產業應用工作坊-互動式分析平台工作坊
# date    : 2015.6.5
# file    : runAPP.R
# author  : Ming-Chang Lee (李明昌)
# email   : alan9956@gmail.com
# RWEPA   : http://rwepa.blogspot.tw/
# encoding: UTF-8

# 安裝套件 -----
# install.packages("shiny")
# install.packages("googleVis")
# install.packages("XLConnect")
# install.packages("devtools")
# devtools::install_github("rstudio/DT")

# shiny 套件 -----
library(shiny)
runExample("01_hello")

# XLConnect 套件 -----
library(XLConnect)
vignette("XLConnect")

# RWepa銷售分析系統v.0.3.1 -----
workpath <- "D:/"
setwd(workpath)
library(shiny)
runApp("retail")
# end
