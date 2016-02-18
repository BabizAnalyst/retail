# title   : 2015資料科學與產業應用工作坊-互動式分析平台工作坊
# date    : 2015.6.5
# file    : ui.R
# author  : Ming-Chang Lee (李明昌)
# email   : alan9956@gmail.com
# RWEPA   : http://rwepa.blogspot.tw/
# encoding: UTF-8

shinyUI(navbarPage("RWepa銷售分析系統v.0.3.1",
                   
                   tabPanel("檔案匯入",
                            sidebarLayout(
                              sidebarPanel(
                                fileInput("file1",
                                          "上傳 Excel 檔案")
                              ),
                              mainPanel(
                                textOutput("text1")
                                )
                              )
                   ),
                   
                   tabPanel("分店資料檢視",
                            sidebarLayout(
                              sidebarPanel(
                                checkboxInput("store.duplicate", "刪除重複值分店", FALSE)
                              ),
                              mainPanel(
                                DT::dataTableOutput("mytable1"),
                                DT::dataTableOutput("mytable1.duplicate")
                              )
                            )
                   ),                   

                   tabPanel("交易資料檢視",
                            sidebarLayout(
                              sidebarPanel(
                                dateRangeInput("dates", 
                                               "選取日期範圍",
                                               start="2009-01-01",
                                               end=  Sys.Date()),
                                selectInput("stateName", "選取州別", 
                                            c("全部"       = "ALL",
                                              "印第安納州(IN)" = "IN", 
                                              "肯塔基州(KY)"   = "KY", 
                                              "俄亥俄州(OH)"   = "OH", 
                                              "德克薩斯州(TX)" = "TX"),
                                            selected="ALL")
                              ),
                              mainPanel(
                                textOutput("dataMessage"),
                                DT::dataTableOutput("mytable2")
                              )
                            )
                   ),
                   tabPanel("視覺化圖表",
                            sidebarLayout(
                              sidebarPanel(
                                radioButtons("visRadio", label="選取分析類別",
                                             c("儀表板圖"="gauge", 
                                               "長條圖"="barchart"), 
                                             selected="gauge")
                              ),
                              mainPanel(
                                htmlOutput("view1")
                              )
                            )
                   ),
                   
                   tabPanel("時間推移圖",
                            sidebarLayout(
                              sidebarPanel(
                                selectInput("stateSelect", "選取州別", 
                                            c("印第安納州(IN)" = "IN", 
                                              "肯塔基州(KY)"   = "KY", 
                                              "俄亥俄州(OH)"   = "OH", 
                                              "德克薩斯州(TX)" = "TX"),
                                            selected="IN")
                              ),
                              mainPanel(
                                htmlOutput("view2")
                              )
                            )
                   ),
        
                   tabPanel("資料摘要", 
                            verbatimTextOutput("summary")
                   )

  ))