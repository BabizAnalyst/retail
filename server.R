# title   : 2015資料科學與產業應用工作坊-互動式分析平台工作坊
# date    : 2015.6.5
# file    : server.R
# author  : Ming-Chang Lee (李明昌)
# email   : alan9956@gmail.com
# RWEPA   : http://rwepa.blogspot.tw/
# encoding: UTF-8

suppressPackageStartupMessages(library(googleVis))
options(shiny.maxRequestSize=4000*1024^2) # max filesize=4GB
options(java.parameters = "-Xmx8192m")

require(XLConnect)
require(DT)
require(googleVis)

progShow <- function(showLabels="資料處理 ... ") {
  withProgress(message = showLabels, value = 0, {
  n <- 100
  for (i in 1:n) {
    incProgress(1/n, detail = paste(i, "%", sep=""))
    Sys.sleep(0.05) # 暫停 0.05 秒
    }
    })
  }
# 
# if (length(dir("data")) != 0) {
# 
#   selectfile <- paste(getwd(), "retail/data/breakfasts_s.RData", sep="")
#   load(selectfile)
# }
shinyServer(function(input, output) {
  
  # 檔案匯入
  output$text1 <- renderText({
    inFile <- input$file1
    if (is.null(inFile))
      return("請選取檔案")
    
    if (is.null(inFile) == FALSE) {
      
      fileMain <- unlist(strsplit(inFile$name, "[.]"))[[1]]
      fileExt <- tolower(unlist(strsplit(inFile$name, "[.]"))[[2]])
      
      if (fileExt == "xlsx" | fileExt == "xls") {
        progShow("資料載入 ... ")
        excelname <- loadWorkbook(inFile$datapath, create=TRUE)
        
        storeSheet <- "dhStoreLookup"
        progShow("商店資料處理 ... ")
        storeData <- readWorksheet(excelname, sheet=storeSheet)
        
        productSheet <- "dhProductsLookup"
        progShow("產品資料處理 ... ")
        productData <- readWorksheet(excelname, sheet=productSheet)
        
        transSheet <- "dhTransactionData"
        progShow("交易資料處理 ... ")
        transData <- readWorksheet(excelname, sheet=transSheet)
        transData$WEEK_END_DATE <- as.Date(transData$WEEK_END_DATE)
        
      }
      
      filename <- paste("data/", fileMain, ".RData", sep="")
      progShow("資料儲存 ... ")
      
      save(storeData, productData, transData, file=filename)
      
      message_label <- paste(inFile$name, " 檔案上傳完畢，請選[資料檢視]!", sep="")
      return(message_label)}
  })

  output$dataMessage <- renderText({
    
    if (length(dir("data")) == 0) {
      return("請選取[檔案匯入] !!!")
    }
    else {
      return("檔案已匯入完成!")
    }
  })

  # 分店資料檢視
  output$mytable1 <- DT::renderDataTable({
    
    if (length(dir("data")) == 0) {
      return(NULL)
    }
    else {
      # progShow("資料載入 ... ")
      files <- dir("data", pattern="\\.RData", full.names=TRUE)[1]
      load(files)
    }
    
    if (input$store.duplicate == TRUE) {
      storeData <- storeData[!duplicated(storeData$STORE_ID),]
      names(transData)[2] <- "STORE_ID"
      transData <- merge(transData, storeData[,c(1,2,4)], by="STORE_ID", all.x=TRUE)
      transData <- transData[c(1,13:14,2:12)]
      progShow("分店,交易合併資料更新中 ... ")
      save(storeData, productData, transData, file=files)
    }
    
    datatable(storeData, 
              options=list(pageLength=10,
                           searching=FALSE))

  })
  
  # 分店重覆資料檢視
  output$mytable1.duplicate <- DT::renderDataTable({
    if (length(dir("data")) == 0) {
      return(NULL)
    }
    else {
      files <- dir("data", pattern="\\.RData", full.names=TRUE)[1]
      load(files)
    }
    
    storeData <- storeData[order(storeData$STORE_ID), ]
    
    # verify duplicated(storeData$STORE_ID)
    duplicated.Store_ID <- storeData$STORE_ID[duplicated(storeData$STORE_ID) == TRUE]
    
    datatable(storeData[storeData$STORE_ID %in% duplicated.Store_ID,], 
              options=list(pageLength=10,
                           searching=FALSE))
  })
   
  # 交易資料檢視
  output$mytable2 <- DT::renderDataTable({
    
    if (length(dir("data")) == 0) {
      return(NULL)
    }
    else {
      files <- dir("data", pattern="\\.RData", full.names=TRUE)[1]
      load(files)
    }
    
    mindate <- input$dates[1]
    maxdate <- input$dates[2]
    
    if (input$stateName == "ALL") {
      selectdata <- transData[which(transData$WEEK_END_DATE >= mindate &
                                      transData$WEEK_END_DATE <= maxdate),]
    } else {
      selectdata <- transData[which(transData$WEEK_END_DATE >= mindate &
                                      transData$WEEK_END_DATE <= maxdate & 
                                      transData$ADDRESS_STATE_PROV_CODE == input$stateName),]
    }
    
    datatable(selectdata, 
              options=list(pageLength=10,
                           searching=FALSE))
    })

  # 視覺化圖表
  output$view1 <- renderGvis({
    
    if (length(dir("data")) == 0) {
      return(NULL)
    }
    else {
      files <- dir("data", pattern="\\.RData", full.names=TRUE)[1]
      load(files)
    }
    
    agg.df <- aggregate(transData[,"SPEND"],
                        by=list(transData$ADDRESS_STATE_PROV_CODE),
                        FUN=sum)
    names(agg.df) <- c("StateName", "SUM")

    maxvalue <- max(agg.df[,2])*1.05
    
    if (input$visRadio == "gauge") {
      gvisGauge(agg.df, options=list(min=0, max=maxvalue,
                                     greenFrom=maxvalue/2, greenTo=maxvalue, 
                                     yellowFrom=maxvalue/3, yellowTo=maxvalue/2,
                                     redFrom=0, redTo=maxvalue/3))
    } else {
      gvisColumnChart(agg.df, xvar="StateName", yvar=c("SUM"))
      
    }
    })

  # 時間推移圖
  output$view2 <- renderGvis({
    
    if (length(dir("data")) == 0) {
      return(NULL)
    }
    else {
      files <- dir("data", pattern="\\.RData", full.names=TRUE)[1]
      load(files)
    }
    
    state.IN <- transData[transData$ADDRESS_STATE_PROV_CODE == "IN", c("WEEK_END_DATE","SPEND")]
    state.KY <- transData[transData$ADDRESS_STATE_PROV_CODE == "KY", c("WEEK_END_DATE","SPEND")]
    state.OH <- transData[transData$ADDRESS_STATE_PROV_CODE == "OH", c("WEEK_END_DATE","SPEND")]
    state.TX <- transData[transData$ADDRESS_STATE_PROV_CODE == "TX", c("WEEK_END_DATE","SPEND")]
    
    state.IN <- state.IN[order(state.IN$WEEK_END_DATE),]
    state.KY <- state.IN[order(state.IN$WEEK_END_DATE),]
    state.OH <- state.IN[order(state.IN$WEEK_END_DATE),]
    state.TX <- state.IN[order(state.IN$WEEK_END_DATE),]

    if (input$stateSelect == "KY") {
      selectData <- state.KY
    } else if (input$stateSelect == "OH") {
      selectData <- state.OH
    } else if (input$stateSelect == "TX") {
      selectData <- state.TX
    } else {
      selectData <- state.IN
    }
    gvisLineChart(selectData, xvar="WEEK_END_DATE", yvar=c("SPEND"))
  })
  
  # 資料摘要
  output$summary <- renderPrint({
    if (length(dir("data")) == 0) {
      return(NULL)
    }
    else {
      files <- dir("data", pattern="\\.RData", full.names=TRUE)[1]
      load(files)
    }
    summary(transData)
    })
})