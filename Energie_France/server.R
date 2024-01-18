#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
library(conflicted)

conflicts_prefer(plotly::layout)
conflicts_prefer(dplyr::filter)

library(FactoMineR)
library(shiny)
library(ggplot2)
library(tidyr)
library(dplyr)
library(reticulate)
library(plotly)
library(rmarkdown)
library(tidyverse)
library(scales)

function(input, output, session) {
  
  data <- read.csv("./data/origine_elec_clean.csv", header = TRUE, sep = ";")
  
  # Separate datasets for main sources and CO2 emissions
  main_sources_data <- data[data$categorie != "Emission de CO2", ]
  co2_data <- data[data$categorie == "Emission de CO2", ]
  
  # Plot for main sources
  output$origineElec <- renderPlot({
   ggplot(main_sources_data, aes(x = annee, y = as.numeric(valeur), fill = sous_categorie)) +
      geom_col(position = "stack") +
      scale_fill_manual(values = c(
        "Charbon" = "#073b4c",         
        "Fioul" = "#f78c6b",
        "Autres Renouvelables" = "#06d6a0",  
        "Nucléaire" = "#ef476f",      
        "Hydraulique" = "#118ab2",
        "Gaz" = "#ffd166"
      )) +
      labs(title = "Origine de l'électricité par source d'énergie",
           x = "Année",
           y = "Pourcentage") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better visibility
  })
  
  # Plot for CO2 emissions with a secondary y-axis
  # Plot for CO2 emissions with a secondary y-axis
  output$emissionCO2 <- renderPlot({
    ggplot(co2_data, aes(x = annee, y = as.numeric(valeur), fill = sous_categorie)) +
      geom_col(position = "stack") +
      scale_fill_manual(values = c(
        "CO2" = "#073b4c"
      )) +
      labs(title = "Émission de CO2 par unité produite d'élécticité",
           x = "Année",
           y = "gCO2/kWh fourni") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels
  }) 	
  
  # Assuming data is your data frame
  data <- read.csv("./data/indisponibilite-moyens-prod-clean.csv", header = TRUE, sep = ";")
  
  # Convert date_de_debut to a date format if it's not already
  data$date_de_debut <- as.Date(data$date_de_debut)
  
  # Extract year and month from the date columns
  data$month_year <- format(data$date_de_debut, "%b %Y")
  
  # Set the price per MWh
  price_per_kWh <- 168.33
  
  
  
  # Calculate the total money lost
  data$total_diff_power <- data$puissance_maximale_mw - data$puissance_disponible_mw
  data_filtered <- data %>%
    filter(!is.na(total_diff_power)) %>%
    group_by(month_year) %>%
    summarise(
      total_diff_power = sum(total_diff_power),
      total_money_lost = sum(total_diff_power) * price_per_kWh
    )
  
  # Normalize the Money Lost values
  max_money_lost <- max(data_filtered$total_money_lost)
  sf <- max(data_filtered$total_diff_power) / max_money_lost
  
  # Divide the money values by 1000
  data_filtered <- data_filtered %>%
    mutate(total_money_lost_scaled = total_money_lost / 100)
  
  # Manually specify the order of levels for month_year
  custom_order <- c("févr. 2022", "janv. 2023", "févr. 2023", 
                    "mars 2023", "avr. 2023", "mai 2023", "juin 2023", "juil. 2023", "août 2023", "sept. 2023", 
                    "oct. 2023", "nov. 2023", "déc. 2023")
  # Des fois il se met en anglais des fois en francais je ne sais pas pourquoi...
  
  # Manually specify the order of levels for month_year
  #custom_order <- c("Feb 2022", "Jan 2023", "Feb 2023", 
  #                  "Mar 2023", "Apr 2023", "May 2023", "Jun 2023", "Jul 2023", "Aug 2023", "Sep 2023", 
  #                  "Oct 2023", "Nov 2023", "Dec 2023")
  
  # Transform
  DF_long <- data_filtered %>%
    pivot_longer(
      cols = c(total_diff_power, total_money_lost_scaled),
      names_to = "Type",
      values_to = "scaled_value"
    )
  
  
  # Convert month_year to a factor with the custom order
  DF_long$month_year <- factor(DF_long$month_year, levels = custom_order)
  
  # Plot
  output$manqueProd <- renderPlot({
    ggplot(DF_long, aes(x = month_year, y = scaled_value, fill = Type)) +
      geom_col(position = "dodge") +
      scale_y_continuous(
        name = "Difference prod en Mwh",
        labels = scales::comma,
        sec.axis = sec_axis(~ . / 100, name = "Manque à gagner en k€", labels = scales::comma)
      ) +
      labs(y = "Difference prod en Mwh") +
      labs(x = 'Mois') + 
      scale_fill_manual(values = c("darkslateblue", "brown1")) +
      theme_bw() +
      theme(
        legend.position = 'top',
        plot.title = element_text(color = 'black', face = 'bold', hjust = 0.5),
        axis.text = element_text(color = 'black', face = 'bold', size = 8),
        axis.title = element_text(color = 'black', face = 'bold'),
        legend.text = element_text(color = 'black', face = 'bold'),
        legend.title = element_text(color = 'black', face = 'bold'),
        axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels
        plot.margin = margin(l = 30, r = 30, t = 10, b = 10, unit = "pt")  # Adjust the margins
      ) +
      ggtitle('Manque de production des centrales nucleaires françaises en 2023')
  })
  
  # Assuming data is your data frame
  data2 <- read.csv("./data/disponibilite-du-parc-nucleaire-d-edf-sa-depuis-2002-clean.csv", header = TRUE, sep = ";")
  
  # Create a plot with lines and colored area underneath
  output$disponibiliteCentrales <- renderPlot({
    ggplot(data2, aes(x = annee, y = coefficient_de_disponibilite)) +
      geom_line(color = "darkslateblue", size = 1.5) +
      geom_ribbon(aes(ymin = 0, ymax = coefficient_de_disponibilite), fill = "lightblue", alpha = 0.5) +
      ggtitle("Disponnibilité des centrales nucleaires depuis 2002") +
      xlab("Annee") +
      ylab("Pourcentage de disponnibilité") +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(color = 'darkslateblue', face = 'bold', hjust = 0.5),
        axis.text = element_text(color = 'black', face = 'bold'),
        axis.title = element_text(color = 'black', face = 'bold')
      )
  })
  
  
  # Read the data
  conso <- read.csv("./data/conso_annuelle_clean.csv", sep=";")
  
  # Consommation par secteur
  # Je récupère les listes des "libelle_grand_secteur" pour connaitre les valeurs possibles de cette variable
  libelle_grand_secteur <- unique(conso$libelle_grand_secteur)
  
  # Je récupère la liste unique de la colonne "annee" pour connaitre les valeurs possibles de cette variable
  annee <- unique(conso$annee)
  
  # Je calcule la consommation par secteur par année
  conso_secteur_annee <- aggregate(conso ~ libelle_grand_secteur + annee, data = conso, FUN = sum)
  conso_secteur_annee
  
  # Je fais un graphe geomline qui me permet de voir l'évolution de la consommation par secteur au cours des années
  # Je l'affiche avec renderPlot
  output$graphique_conso_secteur <- renderPlot({
    
    ggplot(data = conso_secteur_annee, aes(x = annee, y = conso, group = libelle_grand_secteur, color = libelle_grand_secteur)) + 
      geom_line() + 
      geom_point() + 
      labs(title = "Evolution de la consommation par secteur au cours des années", 
           x = "Année", 
           y = "Consommation (MWh)") + 
      theme(legend.position = "bottom",
            axis.text.x = element_text(angle = 45, hjust = 1)) +  # Ajuste l'angle des étiquettes sur l'axe x
      scale_y_continuous(labels = scales::comma) +  # Utilise la virgule comme séparateur de milliers
      scale_x_discrete(breaks = annee)
    
  })
  
  
  # Je récupère les listes des "filiere" pour connaitre les valeurs possibles de cette variable
  filieres <- unique(conso$filiere)
  filieres
  
  
  # Je calcule la consommation par secteur par année
  conso_filiere_annee <- aggregate(conso ~ filiere + annee, data = conso, FUN = sum)
  conso_filiere_annee
  
  # Je fais un graphe geomline qui me permet de voir l'évolution de la consommation par secteur au cours des années
  # Je l'affiche avec renderPlot
  output$graphique_conso_filiere <- renderPlot({
    
    ggplot(data = conso_filiere_annee, aes(x = annee, y = conso, group = filiere, color = filiere)) + 
      geom_line() + 
      geom_point() + 
      labs(title = "Evolution de la consommation par type d'énergie au cours des années", 
           x = "Année", 
           y = "Consommation (MWh)") + 
      theme(legend.position = "bottom",
            axis.text.x = element_text(angle = 45, hjust = 1)) +  # Ajuste l'angle des étiquettes sur l'axe x
      scale_y_continuous(labels = scales::comma) +  # Utilise la virgule comme séparateur de milliers
      scale_x_discrete(breaks = annee)
    
  })
  
  
  # Création du graphique en barres empilées de la consommation pour le secteur électricité
  # Je l'affiche avec renderPlot
  output$graphique_conso_secteur_elec <- renderPlot({
    
    ggplot(data = conso[conso$filiere == "Electricité",], aes(x = annee, y = conso, fill = libelle_grand_secteur)) + 
      geom_bar(stat = "identity", position = "fill") + 
      labs(title = "Répartition de la consommation d'électricité par secteur au cours des années", 
           x = "Année", 
           y = "Consommation (MWh)") + 
      theme(legend.position = "bottom",
            axis.text.x = element_text(angle = 45, hjust = 1)) +  # Ajuste l'angle des étiquettes sur l'axe x
      scale_y_continuous(labels = scales::comma) +  # Utilise la virgule comme séparateur de milliers
      scale_x_discrete(breaks = annee)
    
  })
  
  # Création du graphique en barres empilées de la consommation pour le secteur gaz
  # Je l'affiche avec renderPlot
  output$graphique_conso_secteur_gaz <- renderPlot({
    
    ggplot(data = conso[conso$filiere == "Gaz",], aes(x = annee, y = conso, fill = libelle_grand_secteur)) + 
      geom_bar(stat = "identity", position = "fill") + 
      labs(title = "Répartition de la consommation de gaz par secteur au cours des années", 
           x = "Année", 
           y = "Consommation (MWh)") + 
      theme(legend.position = "bottom",
            axis.text.x = element_text(angle = 45, hjust = 1)) +  # Ajuste l'angle des étiquettes sur l'axe x
      scale_y_continuous(labels = scales::comma) +  # Utilise la virgule comme séparateur de milliers
      scale_x_discrete(breaks = annee)
  })
  
    # Knit du document Rmd
  rmarkdown::render("./data/acp/acp.Rmd", output_format = "html_document")

  # Affichage du graphique ACP
  output$acp <- renderUI({
    includeHTML("./data/acp/acp.html")
  })

  # Affichage du .html de la conso annuelle
  output$consoAnnuelle <- renderUI({
    includeHTML("./data/conso_annuelle2.html")
  })

  # Affichage du .html de l'import export
  output$importExport <- renderUI({
    includeHTML("./data/import_export.html")
  })

  # Knit du document Rmd
  rmarkdown::render("./data/import_export/import_export.Rmd", output_format = "html_document")

  # Affichage du Rmd sur l'import export
  output$importExport <- renderUI({
    includeHTML("./data/import_export/import_export.html")
  })
}
