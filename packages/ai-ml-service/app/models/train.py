import os
import argparse
import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
from tensorflow.keras.callbacks import EarlyStopping
import psycopg2
from app.core.config import settings
import joblib

# --- Configuration ---
MODEL_DIR = "saved_models"
os.makedirs(MODEL_DIR, exist_ok=True)

# --- Database Functions ---
def get_db_connection():
    """Establishes and returns a database connection."""
    return psycopg2.connect(settings.DATABASE_URL)

def fetch_features_data(conn, metric_name='cpu_util_pct'):
    """Fetches time-series data from the features table for a given metric."""
    query = f"SELECT ts, value FROM features WHERE metric_name = '{metric_name}' AND feature_name = 'trend' ORDER BY ts"
    df = pd.read_sql(query, conn, index_col='ts', parse_dates=True)
    return df

def register_model(conn, metric_name, horizon_min, model_name, version, storage_uri, train_start, train_end, metrics):
    """Inserts a new model record into the model_registry table."""
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO model_registry (metric_name, horizon_min, model_name, framework, version_tag, storage_uri, train_start, train_end, metrics)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (metric_name, horizon_min, version_tag) DO NOTHING;
            """,
            (metric_name, horizon_min, model_name, 'tensorflow', version, storage_uri, train_start, train_end, metrics)
        )
    conn.commit()

# --- Data Preprocessing ---
def create_sequences(data, n_steps):
    """Creates input sequences and corresponding labels for the LSTM."""
    X, y = [], []
    for i in range(len(data)):
        end_ix = i + n_steps
        if end_ix > len(data) - 1:
            break
        seq_x, seq_y = data[i:end_ix], data[end_ix]
        X.append(seq_x)
        y.append(seq_y)
    return np.array(X), np.array(y)

# --- Model ---
def build_lstm_model(n_steps, n_features):
    """Defines and compiles a simple LSTM model."""
    model = Sequential([
        LSTM(50, activation='relu', input_shape=(n_steps, n_features)),
        Dense(1)
    ])
    model.compile(optimizer='adam', loss='mse')
    return model

# --- Main Training Script ---
def main(metric_name, model_name, version, epochs, batch_size):
    """Main function to run the training workflow."""
    print("--- Starting Model Training Workflow ---")
    
    # 1. Fetch data
    print("1. Fetching data from the database...")
    conn = get_db_connection()
    df = fetch_features_data(conn, metric_name)
    if df.empty:
        print(f"No feature data found for metric '{metric_name}'. Exiting.")
        return
        
    train_start, train_end = df.index.min(), df.index.max()
    print(f"Data fetched for the period: {train_start} to {train_end}")

    # 2. Preprocess data
    print("2. Preprocessing data...")
    scaler = MinMaxScaler()
    scaled_data = scaler.fit_transform(df)
    
    n_steps = 60  # Using 60 minutes of past data to predict the next minute
    X, y = create_sequences(scaled_data, n_steps)
    if len(X) == 0:
        print(f"Not enough data to create sequences with n_steps={n_steps}. Exiting.")
        return

    n_features = 1
    X = X.reshape((X.shape[0], X.shape[1], n_features))

    # 3. Build and train model
    print("3. Building and training the LSTM model...")
    model = build_lstm_model(n_steps, n_features)
    early_stopping = EarlyStopping(monitor='loss', patience=10, restore_best_weights=True)
    
    history = model.fit(
        X, y,
        epochs=epochs,
        batch_size=batch_size,
        verbose=1,
        callbacks=[early_stopping]
    )

    # 4. Save model and scaler
    print("4. Saving model artifact and scaler...")
    model_filename = f"{model_name}_{version}.h5"
    scaler_filename = f"{model_name}_{version}_scaler.joblib"
    model_path = os.path.join(MODEL_DIR, model_filename)
    scaler_path = os.path.join(MODEL_DIR, scaler_filename)
    
    model.save(model_path)
    joblib.dump(scaler, scaler_path)
    print(f"Model saved to: {model_path}")

    # 5. Register model in the database
    print("5. Registering model in the database...")
    final_loss = history.history['loss'][-1]
    eval_metrics = f'{{"loss": {final_loss}}}'  # Storing loss as a JSON string
    
    register_model(conn, metric_name, n_steps, model_name, version, model_path, train_start, train_end, eval_metrics)
    print("Model registered successfully.")
    
    conn.close()
    print("--- Training Workflow Complete ---")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Model Training Script")
    parser.add_argument("--metric-name", type=str, default="cpu_util_pct", help="Metric to train the model on.")
    parser.add_argument("--model-name", type=str, default="cpu_lstm", help="Name of the model.")
    parser.add_argument("--version", type=str, default="v1", help="Version tag for the model.")
    parser.add_argument("--epochs", type=int, default=50, help="Number of training epochs.")
    parser.add_argument("--batch-size", type=int, default=32, help="Training batch size.")
    
    args = parser.parse_args()
    main(args.metric_name, args.model_name, args.version, args.epochs, args.batch_size)
