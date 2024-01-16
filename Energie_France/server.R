#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#library(shiny)
library(ggplot2)
library(tidyr)
library(dplyr)
library(reticulate)
library(plotly)

reticulate::py_install("pandas")
reticulate::py_install("plotly")

function(input, output, session) {
  
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
  custom_order <- c( "févr. 2022", "janv. 2023", "févr. 2023", 
                     "mars 2023", "avr. 2023", "mai 2023", "juin 2023", "juil. 2023", "août 2023", "sept. 2023", 
                     "oct. 2023", "nov. 2023", "déc. 2023")
  
  # Transform
  DF_long <- data_filtered %>%
    pivot_longer(
      cols = c(total_diff_power, total_money_lost_scaled),
      names_to = "Type",
      values_to = "scaled_value"
    )
  
  unique(data$month_year)
  
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
  
  
  # Load required libraries
  library(plotly)
  library(dplyr)
  
  # Read the data
  conso <- read.csv("./data/conso_annuelle_clean.csv", sep=";")
  
  # Convert the 'annee' column to character format
  conso$annee <- as.character(conso$annee)
  
  # Aggregate data
  conso_sum <- conso %>%
    group_by(libelle_region, annee_factor = factor(annee)) %>%
    summarise(conso = sum(conso),
              .groups = 'drop')  # Use 'drop' to return an ungrouped data frame
  
  # Create text column
  conso_sum$text <- paste('Region: ', conso_sum$libelle_region, '<br>Year: ', as.character(conso_sum$annee_factor), '<br>Consumption: ', conso_sum$conso, ' MwH')
  
  
  #  Create Choropleth map with time slider using plot_geo
  fig <- plot_geo(
    data = conso_sum,
    geojson = 'https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/regions-version-simplifiee.geojson',
    featureidkey = 'properties.nom',
    locations = ~libelle_region,
    z = ~conso,
    text = ~text,
    colors = 'viridis',
    colorbar = list(title = "Consommation energie (MwH)")
  ) %>%
    layout(
      title = "Consommation d'énergie en France par région par an",
      geo = list(
        projection = list(type = 'natural earth'),
        center = list(lat = 46.6, lon = 2.2),  # Adjust the center coordinates
        scope = 'europe',
        lataxis_range = c(42, 50),  # Adjust the latitude range
        lonaxis_range = c(-4, 8),  # Adjust the longitude range
        showframe = FALSE,
        coastlinewidth = 0,
        showcoastlines = TRUE
      ),
      sliders = list(
        list(
          active = 0,
          xanchor = "left",
          yanchor = "top",
          currentvalue = list(prefix = "Année : ", visible = TRUE, xanchor = "right"),
          steps = lapply(unique(conso_sum$annee_factor), function(year) {
            frame_data <- conso_sum %>% filter(annee_factor %in% year)
            list(
              label = as.character(year),
              method = "animate",
              args = list(list(
                "geo.z", frame_data$conso,
                "geo.text", frame_data$text,
                "geo.locations", frame_data$libelle_region,
                "slider.value", list(year)
              ), list(redraw = TRUE, fromcurrent = FALSE)),
              value = as.character(year)
              
            )
          })
        )
      )
    )
  
  output$choroplethPlot <- renderPlotly({
    # Create a Plotly plot in R using the Python-generated JSON
   fig
  })
  
  
}
