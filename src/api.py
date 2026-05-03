# api.py

# Import the libraries
import json
import joblib
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict

# Initialize the app
app = FastAPI(
    title = 'Life Expectancy Predictor',
    description = 'Predicts life expectancy based on health and socioeconomic indicators. '
)

# Load the model, scaler, and feature names
with open('model/random_forest_model.pkl', 'rb') as f:
    model = joblib.load(f)

with open('model/scaler.joblib', 'rb') as f:
    scaler = joblib.load(f)

with open('model/feature_names.json', 'r') as f:
    feature_names = json.load(f)

# Define the input schema
class RawInput(BaseModel):
    income_composition_of_resources: float
    hiv_aids: float
    schooling: float
    adult_mortality: float
    bmi: float
    status: int

    # Example for the UI
    class Config:
        schema_extra = {
            'example': {
                "income_composition_of_resources": 0.6,
                "hiv_aids": 0.1,
                "schooling": 12.0,
                "adult_mortality": 150.0,
                "bmi": 25.0,
                "status": 0
            }
        }

# Feature engineering 
def engineer_features(raw: RawInput) -> np.ndarray:
    '''
    Transforms raw inputs into the 8 derived features used in scaler and model.
    Returns a Numpy array of shape (1, 8) with columns in the same order as feature_names.
    '''
    # Extract the raw values to make sure they are float
    income = float(raw.income_composition_of_resources)
    hiv = float(raw.hiv_aids)
    school = float(raw.schooling)
    adult_mortality  = float(raw.adult_mortality)
    bmi = float(raw.bmi)

    # Derive columns
    income_comp_sq = income ** 2
    log_hiv_aids = np.log(hiv + 1)
    schooling_sq = school ** 2
    bmi_sq = bmi ** 2
    mortality_per_bmi = adult_mortality / (bmi + 1)
    mortality_hiv_inter = adult_mortality * hiv

    # Build the feature array
    features = np.array([[
        income_comp_sq,
        log_hiv_aids,
        schooling_sq,
        adult_mortality,
        bmi_sq,
        mortality_per_bmi,
        mortality_hiv_inter,
        float(raw.status)
    ]])

    return features

# Prediction
@app.post('/predict')
def predict(raw_data:RawInput):
    '''
    Accepts raw and feature engineered inputs, scales them, and return the predicted life expectancy.
    '''

    # Compute derived features
    try:
        full_input = engineer_features(raw_data)
    except Exception as e:
        raise HTTPException(status_code = 422, detail = f'Feature engineering error: {str(e)}')
    
    # Scale the input
    features_to_scale = full_input[:, :7]   # Because in our preprocessing step, we did not scale 'status'
    status_col = full_input[:, 7:8]

    scaled_features = scaler.transform(features_to_scale)

    # Combine them back again
    final_input = np.hstack([scaled_features, status_col])

    # Predict
    prediction = model.predict(final_input)[0]

    return {
        'predicted_life_expectancy': round(float(prediction), 2),
        'units': 'years'
    }

# Health check
@app.get('/health')
def health():
    return {'status': 'ok'}