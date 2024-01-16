#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(leaflet)

fluidPage(
  titlePanel("Energie en France"),
  mainPanel(
    plotOutput("manqueProd"),
    plotlyOutput("choroplethPlot"),
    plotOutput("graphique_conso_secteur"),
    plotOutput("graphique_conso_filiere"),
    plotOutput("graphique_conso_secteur_elec"),
    plotOutput("graphique_conso_secteur_gaz")
  )
)
