library(dplyr)

# 1. Read and clean data
data <- read.table("/Users/julie/Downloads/drug_consumption.data", 
                   header = FALSE, sep = ",", stringsAsFactors = FALSE)

colnames(data) <- c("ID", "age", "gender", "education", "country", "ethnicity",
                    "nscore", "escore", "oscore", "ascore", "cscore", 
                    "impulsiveness", "sensation_seeking",
                    "alcohol", "amphetamines", "amyl_nitrite", "benzodiazepine", 
                    "caffeine", "cannabis", "chocolate", "cocaine", "crack", 
                    "ecstasy", "heroin", "ketamine", "legal_highs", "lsd", 
                    "methadone", "mushrooms", "nicotine", "semeron", "vsa")

# Remove over-claimers
data_clean <- data[data$semeron == "CL0", ]
data_clean$semeron <- NULL

# Convert to numeric
data_clean$education <- as.numeric(data_clean$education)
data_clean$gender <- as.numeric(data_clean$gender)

# Add gender label before sampling
data_clean$gender_label <- ifelse(data_clean$gender == 0.48246, "Female", "Male")

# Stratified sampling (by gender_label + education)
set.seed(1)
strat_sample <- data_clean %>%
  group_by(gender_label, education) %>%
  sample_frac(0.2) %>%
  ungroup()

# Create class-to-numeric mapping
class_mapping <- c("CL0" = 0, "CL1" = 1, "CL2" = 2, "CL3" = 3, 
                   "CL4" = 4, "CL5" = 5, "CL6" = 6)

# Drug variables of interest
drug_vars <- c("alcohol", "amphetamines", "amyl_nitrite", "benzodiazepine", 
               "caffeine", "cannabis", "chocolate", "cocaine", "crack", 
               "ecstasy", "heroin", "ketamine", "legal_highs", "lsd", 
               "methadone", "mushrooms", "nicotine", "vsa")

# Apply the mapping to convert CL values to numeric
strat_sample[drug_vars] <- strat_sample[drug_vars] %>%
  lapply(function(x) as.numeric(class_mapping[x]))

# Calculate average consumption per group
avg_drug_consumption <- strat_sample %>%
  group_by(gender_label, education) %>%
  summarise(across(all_of(drug_vars), ~ mean(.x, na.rm = TRUE), .names = "avg_{.col}"))

# Show all columns in output
print(avg_drug_consumption, width = Inf)
avg_per_drug <- strat_sample %>%
  summarise(across(all_of(drug_vars), ~ mean(.x, na.rm = TRUE)))

# Reshape data to long format for easier handling
avg_per_drug_long <- avg_per_drug %>%
  pivot_longer(cols = everything(), names_to = "drug", values_to = "avg_use")

# Plot the average use for each drug
ggplot(avg_per_drug_long, aes(x = reorder(drug, -avg_use), y = avg_use)) +
  geom_col(fill = "steelblue") +
  labs(title = "Average Use for Each Drug (Overall)",
       x = "Drug", y = "Average Use (0–6 Scale)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

library(ggplot2)

strat_sample$avg_drug_use <- strat_sample %>%
  select(all_of(drug_vars)) %>%
  rowMeans(na.rm = TRUE)
avg_overall_by_group <- strat_sample %>%
  group_by(gender_label, education) %>%
  summarise(avg_total_drug_use = mean(avg_drug_use, na.rm = TRUE))
ggplot(avg_overall_by_group, aes(x = education, y = avg_total_drug_use, fill = gender_label)) +
  geom_col(position = "dodge") +
  labs(title = "Average Overall Drug Use by Gender and Education",
       x = "Education (numeric code)", y = "Avg Drug Use (0–6 Scale)",
       fill = "Gender") +
  theme_minimal()

avg_per_drug <- strat_sample %>%
  summarise(across(all_of(drug_vars), ~ mean(.x, na.rm = TRUE)))
library(tidyr)
avg_per_drug_long <- avg_per_drug %>%
  pivot_longer(cols = everything(), names_to = "drug", values_to = "avg_use")
ggplot(avg_per_drug_long, aes(x = reorder(drug, -avg_use), y = avg_use)) +
  geom_col(fill = "steelblue") +
  labs(title = "Average Use for Each Drug",
       x = "Drug", y = "Average Use (0–6 Scale)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

library(tidyr)
library(ggplot2)

target_drugs <- c("alcohol", "nicotine", "cannabis", "vsa", "heroin", "crack")

avg_by_demo <- strat_sample %>%
  group_by(gender_label, education) %>%
  summarise(across(all_of(target_drugs), ~ mean(.x, na.rm = TRUE), .names = "avg_{.col}"))

print(avg_by_demo)


# Reshape to long format
avg_by_demo_long <- avg_by_demo %>%
  pivot_longer(cols = starts_with("avg_"),
               names_to = "drug",
               values_to = "avg_use") %>%
  mutate(drug = gsub("avg_", "", drug))  # remove "avg_" prefix

# Plot
ggplot(avg_by_demo_long, aes(x = factor(education), y = avg_use, fill = gender_label)) +
  geom_col(position = "dodge") +
  facet_wrap(~ drug, scales = "free_y") +
  labs(title = "Drug Use by Gender and Education Level",
       x = "Education (numeric code)", y = "Average Use", fill = "Gender") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



# Fit regression models for the top 3 drugs with gender and education as predictors
regression_results <- lapply(target_drugs, function(drug) {
  formula <- as.formula(paste(drug, "~ gender + education"))
  lm(formula, data = strat_sample)
})

# Print summaries of each regression model
regression_summaries <- lapply(regression_results, summary)
regression_summaries

# Calculate average drug consumption by gender (male vs female)
avg_drug_consumption_gender <- strat_sample %>%
  group_by(gender_label) %>%
  summarise(across(all_of(drug_vars), ~ mean(.x, na.rm = TRUE), .names = "avg_{.col}"))

# Show the results for average drug use by gender
print(avg_drug_consumption_gender, width = Inf)




# Calculate average drug use by education level
avg_drug_use_by_education <- strat_sample %>%
  group_by(education) %>%
  summarise(across(all_of(drug_vars), ~ mean(.x, na.rm = TRUE), .names = "avg_{.col}"))

# Create a new column for total average drug use per education level
avg_drug_use_by_education$avg_total_drug_use <- rowMeans(avg_drug_use_by_education[, -1], na.rm = TRUE)

# Display the result to see the average drug use by education level
print(avg_drug_use_by_education)
# Find the education level with the highest average drug use
most_frequent_education_level <- avg_drug_use_by_education[which.max(avg_drug_use_by_education$avg_total_drug_use), ]

# Display the result
print(paste("The education level with the most frequent drug use is:", most_frequent_education_level$education))
# Reshape data for visualization

# Display the result
print(avg_drug_use_by_education)
# Plot average total drug use by education level
ggplot(avg_drug_use_by_education, aes(x = factor(education), y = avg_total_drug_use, fill = factor(education))) +
  geom_bar(stat = "identity") +
  labs(title = "Average Drug Use by Education Level",
       x = "Education Level", y = "Average Drug Use (0–6 Scale)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



# Calculate the overall drug use for each individual (across all drugs)
strat_sample$avg_drug_use <- rowMeans(strat_sample[, drug_vars], na.rm = TRUE)

# Calculate the variance of overall drug use by gender and education
variance_drug_use_by_gender_education <- strat_sample %>%
  group_by(gender_label, education) %>%
  summarise(variance_avg_drug_use = var(avg_drug_use, na.rm = TRUE))

# Display the result
print(variance_drug_use_by_gender_education)






# Calculate the correlation matrix for the drug variables
drug_correlations <- cor(strat_sample[, drug_vars], use = "complete.obs")

# Load the necessary libraries for visualization
library(ggplot2)
library(reshape2)

# Create a heatmap
ggplot(drug_correlations_melted, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(midpoint = 0, low = "blue", high = "red", mid = "white") +
  geom_text(aes(label = round(value, 2)), color = "black", size = 3) +  # Add numbers inside cells
  labs(title = "Correlation Heatmap of Drug Consumption", x = "Drug", y = "Drug") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))





# Box plot of drug consumption by education and gender
ggplot(strat_sample, aes(x = factor(education), y = avg_drug_use, fill = gender_label)) +
  geom_boxplot() +
  labs(title = "Drug Consumption Distribution by Education Level and Gender",
       x = "Education Level", y = "Average Drug Consumption") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Count the number of responses per gender and education level
responses_per_group <- strat_sample %>%
  group_by(gender_label, education) %>%
  summarise(responses_count = n())

# Display the result
print(responses_per_group)

