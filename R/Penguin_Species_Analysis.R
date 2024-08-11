# Install and load required packages
install.packages("palmerpenguins")
install.packages("GGally")
install.packages("visdat")

library(palmerpenguins)
library(dplyr)
library(ggplot2)
library(GGally)
library(visdat)

# Set custom dark theme with additional styling
custom_theme <- theme_dark() + 
  theme(plot.title = element_text(size = 16, face = "bold"),
        axis.title = element_text(size = 12),
        legend.position = "bottom")
theme_set(custom_theme)

# Display an overview of the penguins dataset
visdat::vis_dat(penguins)

# Show a glimpse of the categorical variables
penguins %>%
  select(where(is.factor)) %>%
  glimpse()

# Create a scatterplot matrix for numerical variables, colored by species
penguins %>%
  select(species, body_mass_g, ends_with("_mm")) %>%
  ggpairs(aes(color = species)) +
  scale_color_manual(values = c("skyblue", "salmon", "lightgreen"))

# Count penguins by species and island, keeping all combinations
species_island_count <- penguins %>%
  count(species, island, .drop = FALSE)

# Print the count of penguins by species and island
print(species_island_count)

# Bar plot showing penguin counts by island and species
ggplot(species_island_count, aes(x = island, y = n, fill = species)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  scale_fill_manual(values = c("skyblue", "salmon", "lightgreen")) +
  coord_flip() +
  labs(title = "Penguin Counts by Island and Species",
       x = "Island",
       y = "Count") +
  facet_wrap(~species)

# Count penguins by species and sex, including missing values
penguins %>%
  count(species, sex, .drop = FALSE) %>%
  print()

# Scatterplot of flipper length vs. body mass, colored by sex, with faceting by species
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = sex, shape = sex), size = 2) +
  scale_color_manual(values = c("lightblue", "lightcoral"), na.translate = FALSE) +
  facet_wrap(~species) +
  labs(title = "Flipper Length vs. Body Mass by Sex",
       x = "Flipper Length (mm)",
       y = "Body Mass (g)")

# Jitter plot showing bill length by species
ggplot(penguins, aes(x = species, y = bill_length_mm)) +
  geom_jitter(aes(color = species), width = 0.2, alpha = 0.7) +
  scale_color_manual(values = c("skyblue", "salmon", "lightgreen")) +
  labs(title = "Bill Length by Species",
       x = "Species",
       y = "Bill Length (mm)")

# Histogram of flipper length, filled by species
ggplot(penguins, aes(x = flipper_length_mm)) +
  geom_histogram(aes(fill = species), alpha = 0.6, position = "identity", bins = 30) +
  scale_fill_manual(values = c("skyblue", "salmon", "lightgreen")) +
  labs(title = "Histogram of Flipper Length by Species",
       x = "Flipper Length (mm)",
       y = "Count")
