# app.r

library(shiny)

# Chargement de l'interface utilisateur depuis ui.R
source("./Energie_France/ui.R")

# Chargement de la logique serveur depuis server.R
source("./Energie_France/server.R")

# Création et lancement de l'application Shiny
shinyApp(ui = ui, server = server)
