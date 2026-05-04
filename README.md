# Life Expectancy Predictor

![Python](https://img.shields.io/badge/Python-3.9%2B-blue) ![FastAPI](https://img.shields.io/badge/FastAPI-0.100%2B-009688) ![scikit-learn](https://img.shields.io/badge/scikit--learn-1.2%2B-orange) ![License: MIT](https://img.shields.io/badge/License-MIT-yellow)

A machine learning project that predicts life expectancy (in years) using health and socioeconomic indicators.  
A **Random Forest** model achieves **R² = 0.958** (RMSE = 1.93) and is served via a **FastAPI** web application.

---

## 📌 Overview

This project answers the question:  
**“Given a set of country‑level health and economic factors, what is the expected life expectancy?”**

I worked on a cleaned and feature‑engineered version of the **WHO Global Health Observatory** data. After exploratory analysis and feature selection, I trained several regression models and selected a **Random Forest** for its high accuracy.  
The model is deployed as a REST API with a simple HTML frontend, allowing users to input values and obtain an instant prediction.

---

## 📂 Dataset

- **Source:** [WHO Global Health Observatory / Kaggle](https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who)
- **Original file:** `life_expectancy_data.csv` – 2938 rows × 22 columns
- **Cleaned file:** `life_expectancy_data_cleaned.csv`
- **Processed file (used for modelling):** `life_expectancy_data_processed.csv`

**Columns include:**
- **Target:** `life_expectancy`
- **Health indicators:** `adult_mortality`, `infant_deaths`, `under_five_deaths`, `hiv/aids`, `bmi`, `hepatitis_b`, `measles`, `polio`, `diphtheria`, `alcohol`, `percentage_expenditure`, `total_expenditure`
- **Socioeconomic:** `schooling`, `income_composition_of_resources`, `gdp`, `population`, `status` (Developing/Developed), `thinness_1_19_years`, `thinness_5_9_years`

### Data Cleaning & Preparation
1. **Handled missing values** – imputed with median for numeric columns, and mode for categorical.
2. **Corrected data types** and fixed inconsistent entries.
3. **Outlier detection** using IQR method, but retained because the data points reflected genuine extremes.
4. **Created a cleaned version** (`life_expectancy_data_cleaned.csv`).

---

## 🔍 Exploratory Data Analysis (EDA)

I performed EDA using both **Python (pandas, matplotlib, seaborn)** and **SQL** to understand relationships:

- **Life expectancy vs. Schooling** – strong positive correlation (r ≈ 0.75)
- **Life expectancy vs. Income composition of resources** – strong positive correlation
- **Life expectancy vs. HIV/AIDS** – negative correlation, especially in Sub‑Saharan Africa
- **Adult mortality** and **BMI** also showed significant non‑linear patterns

Key insights from EDA guided feature engineering and model selection.

---

## 🧪 Feature Engineering & Selection

To capture non‑linearities and interactions, I created derived features:

1. `income_comp_sq` – squared income composition of resources
2. `log_hiv_aids` – log(1 + HIV/AIDS) to reduce skewness
3. `schooling_sq` – squared schooling
4. `bmi_sq` – squared BMI
5. `mortality_per_bmi` – `adult_mortality / (bmi + 1)` (interaction)
6. `mortality_hiv_inter` – `adult_mortality * hiv/aids` (interaction)

I retained:
- `adult_mortality`
- `status` (categorical: 0 = Developing, 1 = Developed)

**Features after selection:** a total of 8 predictors.

**VIF (Variance Inflation Factor)** was checked to ensure no multicollinearity; all selected features had VIF < 10.

Finally, I **scaled** the continuous features using `StandardScaler` (saved as `scaler.joblib`).

---

## 🤖 Modelling

I trained and evaluated multiple regression models:

| Model               | RMSE (years) | MAE (years) | R² Score |
|---------------------|--------------|-------------|----------|
| Dummy Regressor     | 9.45         | 7.76        | 0.0      |
| Linear Regression   | 3.71         | 2.74        | 0.848    |
| Lasso Regression    | 3.63         | 2.69        | 0.852    |
| Ridge Regression    | 3.62         | 2.69        | 0.852    |
| Random Forest       | **1.93**     | **1.20**    | **0.958**|
| XGBoost             | 2.00         | 1.27        | 0.955    |

**Random Forest** was chosen as the final model because of its high accuracy, robustness, and ability to capture non‑linear relationships.

The trained model is saved as `random_forest_model.pkl` and the scaler as `scaler.joblib`.

---

## 🌐 Web Application

A **FastAPI** web app serves the model:

- **Backend:** `api.py` – REST endpoint `/predict` that accepts JSON input, engineers features, scales them, and returns the predicted life expectancy.
- **Frontend:** `index.html` – a simple UI where users can enter values and see the prediction instantly.

**Example API request:**
```json
{
  "income_composition_of_resources": 0.6,
  "hiv_aids": 0.1,
  "schooling": 12.0,
  "adult_mortality": 150.0,
  "bmi": 25.0,
  "status": 0
}
```

**Response:**
```json
{
  "predicted_life_expectancy": 72.45,
  "units": "years"
}
```

## 🚀 How to Run Locally

1. **Clone the repository**
   ```bash
   git clone git@github.com:MohammadErfanRashidi/Life-Expectancy-.git
   cd life-expectancy-predictor
   ```

2. **Create a virtual environment & install dependencies**
   ```bash
   python -m venv venv
   source venv/bin/activate   # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Run the API server**
   ```bash
   uvicorn api:app --reload
   ```

4. **Open the app**
   - Frontend: [http://127.0.0.1:8000](http://127.0.0.1:8000)
   - API docs (Swagger): [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)

## 📁 Project Structure

```
.
├── data
│   ├── life_expectancy_data_cleaned.csv
│   ├── life_expectancy_data.csv
│   └── life_expectancy_data_processed.csv
├── LICENSE
├── notebooks
│   ├── cleaning.ipynb
│   ├── EDA.ipynb
│   ├── modeling.ipynb
│   └── preprocessing.ipynb
├── README.md
├── reports
│   ├── python_EDA_viz
│   │   ├── correlation.png
│   │   ├── distribution.png
│   │   ├── life_expectancy_overtime.png
│   │   ├── pairplot.png
│   │   ├── scatterplot.png
│   │   └── status.png
│   └── sql_eda_results
│       ├── adult_mortality_on_life.csv
│       ├── alcohol_on_life.csv
│       ├── gdp_on_life.csv
│       ├── icr_on_life.csv
│       ├── infant_deaths_on_life.csv
│       ├── schooling_on_life.csv
│       └── status_per_year_on_life.csv
├── requirements.txt
├── sql_EDA
│   └── EDA.sql
└── src
    ├── api.py
    ├── index.html
    └── model
        ├── feature_names.json
        ├── random_forest_model.pkl
        └── scaler.joblib
```

## 🛠️ Technologies Used

- **Python** 3.9+
- **pandas**, **NumPy**, **scikit‑learn**, **XGBoost**
- **Matplotlib**, **Seaborn** (EDA)
- **SQL** (data exploration)
- **FastAPI**, **Uvicorn**, **Pydantic** (web API)
- **HTML/CSS/JavaScript** (frontend)

## 📈 Results & Conclusion

The Random Forest model explains **95.8% of the variance** in life expectancy, meaning the selected features (income, schooling, HIV rate, adult mortality, BMI and their interactions) are extremely predictive.  
This project demonstrates end‑to‑end machine learning: from data cleaning, EDA, feature engineering, model tuning, to API deployment.

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.