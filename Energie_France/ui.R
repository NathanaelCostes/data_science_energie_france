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
  titlePanel("Projet Data Science Analyse de l'énérgie en France"),
  tabsetPanel(
    tabPanel("Accueil", 
             tags$style(HTML("
                .accueil-text {
                  font-size: 16px;
                  color: #333;
                  text-align: justify;
                  margin-bottom: 15px;
                }
                .signature-text {
                  font-size: 14px;
                  font-style: italic;
                  color: #555;
                }
              ")),
             tags$p("Bienvenue sur notre application ! Nous analysons l'état de l'énergie en France en utilisant des données provenant de différentes sources telles que data.gouv, EDF, RTE, ORE. Explorez les onglets pour découvrir des informations sur la production, la consommation, et bien plus encore.", class = "accueil-text"),
             tags$p("Fait par : Aveline Robin, Boudier Léon, Costes Nathanaël, d'Amerval Léo", class = "signature-text")
    ),
    tabPanel("Production ACP", 
             uiOutput("acp"),
             # Add custom CSS and text
             tags$style(HTML("
               .acp-text {
                 font-size: 16px;
                 color: #333;
               }
             ")),
             tags$p("This is some additional text in the 'Production ACP' panel.", class = "acp-text")
    ),
    tabPanel("Origine Electricite",
             tags$div(
               style = "display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%;",
               tags$p("Origine de l'électricité en France", class = "origineElec-text"),
               plotOutput("origineElec")
             ),
             tags$hr(style = "width: 80%;"),  # Add a horizontal line between the plots
             tags$div(
               style = "display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%;",
               tags$p("CO2 émis par production d'électricité", class = "origineElec-text"),
               plotOutput("emissionCO2")
             ),
             tags$style(HTML("
              .origineElec-text {
                font-size: 18px;
                font-weight: bold;
                color: #333;
              }
              "))
    ),
    tabPanel("Disponibilite Centrales", 
             tags$div(
               style = "display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%;",
               tags$p("Disponibilité des centrales nucléaires en France", class = "disponibiliteCentrales-text"),
               plotOutput("disponibiliteCentrales")
             ),
             tags$hr(style = "width: 80%; margin: 15px 0;"),  # Add a horizontal line between the plots
             
             tags$div(
               style = "display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%;",
               tags$p("Manque de production des centrales nucléaires françaises en 2023", class = "disponibiliteCentrales-text"),
               plotOutput("manqueProd")
             ),
             tags$style(HTML("
               .disponibiliteCentrales-text {
                 font-size: 18px;
                 font-weight: bold;
                 color: #333;
               }
             ")),
    ),
    tabPanel("Carte Consommation", 
             uiOutput("consoAnnuelle")
    ),
    tabPanel("Consommation",
             tags$div(
               style = "display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%;",
               tags$p("Graphique de la consommation par secteur", class = "consommation-text"),
               plotOutput("graphique_conso_secteur")
               
             ),
             tags$hr(style = "width: 80%; margin: 15px 0;"),  # Add a horizontal line between the plots
             tags$div(
               style = "display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%;",
               tags$p("Graphique de la consommation par filière", class = "consommation-text"),
               plotOutput("graphique_conso_filiere")
             ),
             tags$hr(style = "width: 80%; margin: 15px 0;"),  # Add another horizontal line
             tags$div(
               style = "display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%;",
               tags$p("Graphique de la consommation par secteur d'électricité", class = "consommation-text"),
               plotOutput("graphique_conso_secteur_elec")
             ),
             tags$hr(style = "width: 80%; margin: 15px 0;"),  # Add another horizontal line
             tags$div(
               style = "display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%;",
               tags$p("Graphique de la consommation par secteur de gaz", class = "consommation-text"),
               plotOutput("graphique_conso_secteur_gaz"),
             ),
             tags$style(HTML("
                .consommation-text {
                  font-size: 18px;
                  font-weight: bold;
                  color: #333;
                }
              "))
    )
    ,
    tabPanel("Import Export", 
             uiOutput("importExport"),
             # Add custom CSS and text
             tags$style(HTML("
               /* Your custom CSS styles for 'Import Export' panel go here */
               .importExport-text {
                 font-size: 16px;
                 color: #333;
               }
             "))    )
  )
)
