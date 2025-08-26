# Data 407 Project – Drug Consumption Analysis

**Author:** Julie Flament  
**Course:** DATA 407  
**Professor:** Xioping Shi  
**Date:** April 8, 2025  

---

## 📌 Project Overview
This project analyzes the [UCI Drug Consumption (Quantified) dataset](https://archive.ics.uci.edu/dataset/373/drug+consumption+quantified), which contains self-reported drug use across multiple demographics.  
The goal was to study how **gender** and **education level** affect drug consumption patterns across substances ranging from legal (alcohol, nicotine) to illegal (heroin, crack).  

The dataset measures usage frequency on a **0–6 scale**:
- `0` = Never Used  
- `6` = Used in Last Day  

---

## 🧹 Methods
1. **Data Cleaning**  
   - Removed over-claimers (respondents who reported using the fake control drug *Semeron*).  
   - Converted categorical CL0–CL6 values into numeric (0–6).  

2. **Sampling**  
   - Applied **stratified sampling** by gender and education to ensure balanced representation.  

3. **Analysis**  
   - Summary statistics & plots of average drug use by group.  
   - Regression models with **gender** and **education** as predictors.  
   - Correlation heatmap across all substances.  

---

## 📊 Key Findings
- **Gender**  
  - Males generally consume drugs more frequently than females.  
  - Gender is especially significant for *VSA, heroin, crack*.  

- **Education**  
  - Higher education levels are associated with lower consumption, especially for *nicotine* and *cannabis*.  
  - For rare/illegal drugs (heroin, VSA, crack), education has less effect.  

---
