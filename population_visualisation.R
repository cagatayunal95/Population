library(sf)
library(dplyr)
library(ggplot2)
library(rayshader)
library(rgl)

# Load the population data
library(readxl)
population_data <- read_excel("population_data.xlsx", 
                              col_types = c("text", "numeric"))

# Load the geospatial data
turkey_map <- tur_polbnda_adm1 <- st_read("C:/Users/cagat/Desktop/geo/tur_polbnda_adm1.shp")

# Calculate the population density
# Assuming 'population' is the column with population figures
# and 'Shape_Area' is in square meters; we convert it to square kilometers
population_data$population_density <- population_data$iki / (turkey_map$Shape_Area / 1e+6)

# Merge the datasets
# Ensure the column names 'adm1_en' in turkey_map and 'bir' in population_data match and are character type
turkey_map$adm1_en <- as.character(turkey_map$adm1_en)
population_data$bir <- as.character(population_data$bir)
merged_data <- left_join(turkey_map, population_data, by = c("adm1_en" = "bir"))

# Create the ggplot object
ggplot_gg <- ggplot(data = merged_data) +
  geom_sf(aes(fill = population_density)) +
  scale_fill_viridis_c() +  # Optional: Add a color scale for aesthetics
  theme_void()  # Remove axes and background

# Use rayshader to create the 3D plot
# Update 'population_density' to match the column name in your merged_data
ggplot_gg %>% 
  plot_gg(width = 6, height = 4, scale = 250, multicore = TRUE) %>% 
  plot_3d(merged_data[["population_density"]], zscale = 0.1, fov = 70, theta = 30, phi = 20, windowsize = c(800, 800))

# To view the plot, use rgl package
rgl::rglwidget()
