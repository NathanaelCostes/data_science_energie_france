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
  tabsetPanel(
    tabPanel("Production ACP", uiOutput("acp")),
    tabPanel("Conso Annuelle", uiOutput("consoAnnuelle")),
    tabPanel("Origine Electricite", plotOutput("origineElec")),
    tabPanel("Emission CO2", plotOutput("emissionCO2")),
    tabPanel("Manque Production", plotOutput("manqueProd")),
    tabPanel("Choropleth Plot", plotlyOutput("choroplethPlot")),
    tabPanel("Conso Secteur", plotOutput("graphique_conso_secteur")),
    tabPanel("Conso Filiere", plotOutput("graphique_conso_filiere")),
    tabPanel("Conso Secteur Electricite", plotOutput("graphique_conso_secteur_elec")),
    tabPanel("Conso Secteur Gaz", plotOutput("graphique_conso_secteur_gaz")),
    tabPanel("Disponibilite Centrales", plotOutput("disponibiliteCentrales")),
    tabPanel("Import Export", uiOutput("importExport")),
  )
)
