

library(shiny)
library(shinydashboard)
shinyUI(
  dashboardPage(
    dashboardHeader(),
    dashboardSidebar(
      sidebarMenu(
        menuItem("upload", tabName = "upload", icon = icon("dashboard")),
        
        menuItem("Analysis", tabName = "analysis", icon = icon("dashboard")),
        menuItem("Visualization ACF & PACF ", tabName = "vis_acf", icon = icon("dashboard")),
        menuItem("Comparison", tabName = "comp", icon = icon("dashboard")),
        menuItem("Forcasted Matched Actual", tabName = "FMA", icon = icon("dashboard"))
      )
    ),
    #-----------------------------------------
    dashboardBody(
      
      tabItems(
        #-------------------first page-------------------------
        # First tab content
        tabItem(
          tabName = "upload",
          fluidRow(
            box(
              width = 12,
              title = "The Dataset Come From Yahoo Website With The Latest Version The previous Day",
              status= "info",
              solidHaider = TRUE,
              collapsible = TRUE,
              actionButton("upload data","Download",class="btn btn-info")
            ),
            box(
              width = 12,
              title = "The Data as Shown Below (This is a Sample of The Data )",
              status= "success",
              solidHaider = TRUE,
              collapsible = TRUE,
              actionButton("sample_data","View Dataset",class="btn btn-info"),
              dataTableOutput("sample_data_t")
            )
            
            
          )
        ),
        tabItem(tabName = "analysis",
                fluidRow(
                  
                  box(
                    width = 12,
                    title = "Ploting Mean of Dataset ",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    plotOutput("plot_close", click = "plot_close")
                   
                  )),
                #---------------
                fluidRow( 
                  box(
                    width = 12,
                    title = "Summary Of The Dataset",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    dataTableOutput("AAPL_summary")
                  )
                   
                  ),
                fluidRow(
                  box(
                    width = 6,
                    title = "Jark Pera Test For Normality ",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    textOutput("jark_pera_test")
                    
                  ),
                  box(
                    width = 6,
                    title = "Kolomogorov and Smirnof Test For Normality ",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    textOutput("kolomogorov_test")
                    
                  )
                ),
                fluidRow(
                  box(
                    width = 12,
                    title = "Histogram Illistrate that The Model is Normally Distrubuted",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    plotOutput("hist_apple_data", click = "hist_apple_data")
                  )
                 ),
                fluidRow(
                  box(
                    width = 12,
                    title = "Questions to be Discused with AAPL market",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    dataTableOutput("document")
                  )
                )
              
                ),
        #------------------------------------------------------------------------------------------------------------
        #----------------------second page -------------------------------------------
        # Second tab content
     
        #---------------------------------third page---------------------------------------------------------------------------
        # Third tab content
        tabItem(tabName = "vis_acf",
                fluidRow(
                  box(
                    width = 12,
                    title = "Ploting of Stationary",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    plotOutput("plot_stationary", click = "plot_stationary")
                  )),
                fluidRow(
                  box(
                    width = 6,
                    title = "ploting ACF",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    plotOutput("plot_acf", click = "plot_acf")
                    
                  ),
                  box(
                    width = 6,
                    title = "ploting PACF",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    plotOutput("plot_pacf", click = "plot_pacf")
                  )
                  
                  
                )
                
                
        ),
        #---------------------------------------fourth-----------------------
        # Fourth tab content
        
        tabItem(tabName = "comp",
                fluidRow(
                  box(
                    width = 12,
                    title = "Actual and Forecasted plot (Black is Actual) (Red is Forecasted)",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    plotOutput("plot_afp", click = "plot_afp")
                    
                  ),
                  
                  box(
                    width = 12,
                    title = "View Comparison",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    dataTableOutput("my_comparison")
                    
                    
                  )
                  
                )
                
                
        ),
        
        #---------------------------------------fifth-----------------------
        # Fifth tab content
        
        tabItem(tabName = "FMA",
                fluidRow(
                  box(
                    width = 12,
                    title = "percentage of comparison of the actual and forcasted values  ",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    valueBoxOutput("Accuracy_Box"),
                  box(
                    width = 12,
                    title = "Coefficient of ARIMA Model  ",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    tableOutput("arima_coeff")
                    
                  ),
                  box(
                    width = 12,
                    title = "ME $ MSE  ",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    tableOutput("arima_ME")
                    
                  )
          
                )
        )
        #-----------------------------------------------------------------------

      )
      
    )
  )
))
