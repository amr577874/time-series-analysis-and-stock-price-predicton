
library(shiny)
library(quantmod)
library(tseries)
library(timeSeries)
library(forecast)
library(xts)

# Define server logic required to draw a histogram
shinyServer(function(input , output){
  ## Run area
  observeEvent(input$`upload data`,{
    upload_data(input , output)
    plot_close(input,output)
    #if_Stationary(input,output)
    plot_stationary(input,output)
    analysis(input,output)
    plot_acf_pacf(input,output)
    comparison (input,output)
    view_accuracy(input,output)
  })
  
  observeEvent(input$sample_data , {
    view_sample(input,output)
    #plot_close(input,output)
  })
  observeEvent(input$all_data , {
    view_all_data(input,output)
  })
  
})
##################   Functions Area###########################
upload_data <- function(input,output)
{
  AAPL <- AAPL
  #getSymbols('AAPL',src='yahoo' ,from='2016-01-01')
  return(AAPL)
}

view_sample <- function(input,output)
{
  df <- upload_data(input,output)
  output$sample_data_t<- renderDataTable({
    return(head(df))
  },options = list(scrollX=TRUE))
}

#view_all_data <- function(input,output)
#{
#  df <- upload_data(input,output)
#  output$all_data <- renderDataTable({
#    return(df)
#  },options = list(scrollX=TRUE))
#}

plot_close <- function(input,output)
{
  AAPL = upload_data(input,output)
  AAPL$mean11 <- ((AAPL$AAPL.Open + AAPL$AAPL.High + AAPL$AAPL.Low + AAPL$AAPL.Close)/4)
  stock_prices = AAPL$mean11
  output$plot_close <- renderPlot({
    plot(stock_prices)
  })
  return(stock_prices)
}
#function to test if the data is stationary or not
if_Stationary <- function(input,output){
  stock_prices <- plot_close(input,output)
  
  output$ar_out <-renderValueBox({
    auto.arima(stock_prices)
  },options = list(scrollX=TRUE))
}
  plot_stationary <- function(input,output)
  {
    stock_prices <-plot_close(input,output) 
    stock = diff(log(stock_prices),lag=1)
    stock = stock[!is.na(stock)]
    output$plot_stationary <- renderPlot({
      plot(stock)
    })
    return(stock)
  }
  plot_acf_pacf <- function(input,output)
  {
    stock <-plot_stationary(input,output)
    breakpoint = floor(nrow(stock)*(4.9/5))
    output$plot_acf <- renderPlot({
      acf.stock = acf(stock[c(1:breakpoint),], main='ACF Plot')
    })
    output$plot_pacf <- renderPlot({
      pacf.stock = pacf(stock[c(1:breakpoint),], main='PACF Plot')
    })
    return(breakpoint)
  }
  comparison <-function(input,output){
    stock_prices <-plot_close(input,output)
    stock <-plot_stationary(input,output)
    breakpoint <-plot_acf_pacf(input,output)
    Actual_series = xts(0,as.Date("2018-11-01","%Y-%m-%d"))
    forecasted_series = data.frame(Forecasted = numeric())
    for (b in breakpoint:(nrow(stock)-1)) {
      stock_train = stock[1:b, ]
      stock_test = stock[(b+1):nrow(stock), ]
      # Summary of the ARIMA model using the determined (p,d,q) parameters
      fit <<- arima(stock_train, order = c(1, 0, 4),include.mean=FALSE)
      summary(fit)
      
      # Forecasting the log returns
      arima.forecast = forecast(fit, h = 1,level=99)
      
      #plot(arima.forecast, main = "ARIMA Forecast")
      # Creating a series of forecasted returns for the forecasted period
      forecasted_series = rbind(forecasted_series,arima.forecast$mean[1])
      colnames(forecasted_series) = c("Forecasted")
      # Creating a series of actual returns for the forecasted period
      Actual_return = stock[(b+1),]
      Actual_series = c(Actual_series,xts(Actual_return))
      rm(Actual_return)
      #print(stock_prices[(b+1),])
      #print(stock_prices[(b+2),])
    }
    output$arima_ME <- renderTable(spacing ="l" , digits = 10 ,{
      
      return(accuracy(fit))
    })
    output$arima_coeff <- renderTable({
     return(as.table(arima.forecast$model$coef))
    })
    arima.forecast$model$coef
    Actual_series = Actual_series[-1]
    forecasted_series = xts(forecasted_series,index(Actual_series))
    
    output$plot_afp<- renderPlot({
      plot(Actual_series,main='Actual Returns Vs Forecasted Returns');
      lines(forecasted_series,col='red');
    })
    
    comparsion = merge(Actual_series,forecasted_series)
    comparsion$Comparison = sign(comparsion$Actual_series)==sign(comparsion$Forecasted)
    Accuracy_percentage = sum(comparsion$Comparison == 1)*100/length(comparsion$Comparison)
    
     output$my_comparison <- renderDataTable({
      return(comparsion )
    },options = list(scrollX=TRUE))
     
     return(Accuracy_percentage)
  }
  
  view_accuracy <-function(input,output){
    df <-comparison(input,output)
    output$Accuracy_Box <- renderValueBox({
      valueBox(
        paste0(df,"%"),"Forecasted Matched Actual With",color = "aqua",width = 20
        ,icon = icon("thumbs-up")
      )
    })
    
    
  }
  
z_score_apple <- function(x,apple_mean,apple_std){
  return ((x-apple_mean)/apple_std)
  }
p_value <- function(x){
  return(1-pnorm(abs(x)))
  }

analysis <- function(input,output){
  #getSymbols('AAPL', from='2015-01-01', to='2018-11-20')
  AAPL <- upload_data(input,output)
 # getSymbols('GE', from='2015-01-01', to='2018-11-20')
  
  data1 <- AAPL
 # data2 <- GE
  
  data1$mean11 <- ((data1$AAPL.Open + data1$AAPL.High + data1$AAPL.Low + data1$AAPL.Close)/4)
  #data2$mean12 <- ((data2$GE.Open + data2$GE.High + data2$GE.Low + data2$GE.Close)/4)
  
  apple_data <- diff(log(data1$mean11),lag=1)*100
  #GE_data <- diff(log(GE$GE.Close),lag=1)*100

  output$AAPL_summary <- renderDataTable({
    return(summary(data1$mean11) )
  },options = list(scrollX=TRUE))
  #summary(coredata(data1$mean11))
  
  apple_data = apple_data[!is.na(apple_data)]
  #GE_data = GE_data[!is.na(GE_data)]
  #test if the data is normally distributed or not with jarque bera test
  jarque.bera.test(apple_data)
  #jarque.bera.test(GE_data)
  output$jark_pera_test <- renderPrint({
    # aaa <- as.data.frame()
    return(jarque.bera.test(apple_data))
  })
  ##test if the data is normally distributed or not with kolomogorov and smirnof test
  ks.test(apple_data , "pnorm")
  #ks.test(GE_data , "pnorm")
  output$kolomogorov_test <- renderPrint({
    # aaa <- as.data.frame()
    return(ks.test(apple_data , "pnorm"))
  })
 # hist(apple_data, breaks = 150)
  output$hist_apple_data<- renderPlot({
    hist(apple_data, breaks = 150)
  })
  
  apple_mean <- mean(apple_data)
  apple_std <- sd(apple_data)
  
  p_value_apple_return_greater_0.5 <- p_value(z_score_apple(0.5,apple_mean,apple_std))
  
  p_value_apple_loss_greater_2 <-p_value(z_score_apple(-2,apple_mean,apple_std))
 
  #for apple
  p_value_apple_return_greater_0 <-p_value(z_score_apple(0,apple_mean,apple_std))
  p_value_apple_return_greater_1 <-p_value(z_score_apple(1,apple_mean,apple_std))
  p_value_apple_return_between01 <- (1-p_value_apple_return_greater_0 +p_value_apple_return_greater_1 )
 
  #what is the probability for any given day of a return OR loss greater than 3%
  #for apple 
  p_value_apple_return_greater_3 <- p_value(z_score_apple(3,apple_mean,apple_std))
  p_value_apple_loss_greater_3 <- p_value(z_score_apple(-3,apple_mean,apple_std))
  p_value_apple_return_plus_loss_on_3 <- p_value_apple_return_greater_3 + p_value_apple_loss_greater_3
 
  question <- c("what is the probability for any given day of a return greater than 0.5%",
                "what is the probability for any given daty of a loss greater than 2%",
                "what is the probability for any givin daty of a return is between 0% and 1%",
                "what is the probability for any given day of a return OR loss greater than 3%"
  )
  
  
  apple <- c(p_value_apple_return_greater_0.5 ,p_value_apple_loss_greater_2 ,
             p_value_apple_return_between01 , p_value_apple_return_plus_loss_on_3)
  #ge <- c(p_value_ge_return_greater_0.5 , p_value_ge_loss_greater_2,
   #       p_value_ge_return_between01 , p_value_ge_return_plus_loss_on_3)
  
  document <- data.frame(question , apple)
  output$document <- renderDataTable({
    return(document)
  },options = list(scrollX=TRUE))
  #View(document)
}
  