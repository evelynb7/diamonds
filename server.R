#
# This is the server logic of the Diamonds Shiny web application.
#

library(shiny)
library(ggplot2)
library(plotly)
library(scales)
library(knitr)

rmdfiles <- c("intro.rmd")
sapply(rmdfiles, knit, quiet = T)

shinyServer(function(input, output, session) {
   
  myData <- diamonds
  
  set.seed(123)
  
  inSample <- sample.int(n = nrow(myData),
                         size = floor(0.1*nrow(myData)), replace = FALSE)
  sampleDF <- myData[inSample, ]
  
  mdl <- lm(I(log10(price)) ~ I(carat^(1/3)) + carat + cut + clarity + color, 
            data = sampleDF)
  
  prediction <- reactive({
    inCarat <- input$carat
    inCut <- input$cut
    inClarity <- input$clarity
    inColor <- input$color
    
    newDF <- data.frame(carat = inCarat,
                        cut = inCut,
                        clarity = inClarity,
                        color = inColor)
    
    predict(mdl, newdata = newDF,
            interval = "prediction", level = .95)
  })
  
  ### Render plotly chart
  
  output$iplot <- renderUI({
    plotlyOutput("plot")
  })
  
  ### Custom cube root scaling function
  
  cuberoot_trans <- function(){
    trans_new("cuberoot",
              transform = function(x) x^(1/3),
              inverse = function(x) x^3)
  }
  
  ### Plotly chart
  
  output$plot <- renderPlotly({
    predictDF <- data.frame("carat" = input$carat, 
                            "price" = round(10^prediction()[1],0))
    
    
    g <- ggplot(data=sampleDF, 
                aes(x = carat, y = price, 
                    text = paste("<b>Price:</b> $", format(price, big.mark = ","),
                                 "</br><b>Carat:</b>"," ", carat, sep = ""))) +
      geom_point(alpha = 0.5, 
                 size = 1, 
                 position = "jitter",
                 aes_string(color = tolower(input$view))) +
      geom_point(data = predictDF, 
                 aes(x = carat, y = price), pch = 8) +
      scale_color_brewer(type = 'div', palette = "Set3",
                         guide = guide_legend(title = input$view, reverse = T,
                                              override.aes = list(alpha = 1, size = 2))) +
      scale_x_continuous(trans = cuberoot_trans()) +
      scale_y_continuous(trans = log10_trans(), 
                         breaks = pretty(sampleDF$price, n = 5)) +
      labs(title = "Price by Carat", x = "Carat", y = "Price (US$)")
    
    ggplotly(g, tooltip = c("text"))
    
  })
  
  ### Render UI for filter controls
  
  output$icarat <- renderUI({
    sliderInput("carat",
                "Select carat",
                value = 1,
                min = min(sampleDF$carat),
                max = round(max(sampleDF$carat),0),
                step = 0.01
    )
  })
  
  output$icut <- renderUI({
    selectInput("cut",
                "Cut",
                choices = c(sort(unique(as.character(sampleDF$cut)))),
                selected = "Ideal"
    )
  })
  
  output$icolor <- renderUI({
    selectInput("color",
                "Colour",
                choices = c(sort(unique(as.character(sampleDF$color)))),
                selected = "I"
    )
  })
  
  output$iclarity <- renderUI({
    selectInput("clarity",
                "Clarity",
                choices = c(sort(unique(as.character(sampleDF$clarity)))),
                selected = "VS2"
    )
  })
  
  output$iview <- renderUI({
    radioButtons("view", 
                 "View by",
                 choices = c("Cut", "Color", "Clarity"), inline = TRUE
    )
  })
  
  output$ipredict <- renderUI({
    textOutput("predict")
  })
  
  observe({
    output$predict <- renderText({
      paste("Price estimate: $", format(round(10^prediction()[1],0), big.mark = ","), sep = "")
    })
  })
  
  output$ireset <- renderUI({
    actionButton("reset", "Reset")
  })
  
  ### Reset function
  
  observe({
    input$reset
    updateSliderInput(session, "carat", value = 1)
    updateSelectInput(session, "cut", selected = "Ideal")
    updateSelectInput(session, "color", selected = "I")
    updateSelectInput(session, "clarity", selected = "VS2")
    updateRadioButtons(session, "view", selected = "Cut")
  })
  
})
