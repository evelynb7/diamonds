#
# This is the user-interface definition of the Diamonds Shiny web application. 
#

library(shiny)
library(shinythemes)

# Define UI for application that calculates diamond price estimates
shinyUI(navbarPage("Diamonds",
                   theme = shinytheme("spacelab"),
                   tabPanel("Introduction",
                            withMathJax(includeMarkdown("intro.md"))
                   ), # end tabPanel "Introduction"
                   tabPanel("Price Estimator",
                            fluidPage(
                              titlePanel("Get an estimate"),
                              sidebarLayout(
                                sidebarPanel(
                                  uiOutput("icarat"),
                                  uiOutput("icut"),
                                  uiOutput("icolor"),
                                  uiOutput("iclarity"),
                                  uiOutput("iview"),
                                  tags$hr(),
                                  strong(uiOutput("ipredict")),
                                  tags$hr(),
                                  uiOutput("ireset")
                                ), # end sidebaPanel
                                mainPanel(
                                  uiOutput("iplot")
                                ) # end mainPanel
                              ) # end sidebarLayout
                            ) # end fluidPage
                   ), #end tabPanel "Price Estimator"
                   tabPanel(HTML("<li><a href=\"http://github.com/evelynb7/diamonds\" target=\"_blank\">Code"))
                   
) # end navbarPage
) # end ShinyUI
