# packages/ai-ml-service/app/services/gemini_service.py
import google.generativeai as genai
import logging
import json
from app.core.config import settings

# --- Configure logging ---
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# --- Configure Gemini API ---
genai.configure(api_key=settings.GEMINI_API_KEY)

class GeminiPredictionService:
    """
    A service to generate time-series predictions using the Gemini API.
    """
    def __init__(self, model_name="gemini-1.5-flash"):
        self.model = genai.GenerativeModel(model_name)

    def generate_mock_prediction(self, historical_data: list, num_points: int, horizon_desc: str) -> list[float]:
        """
        Generates a mock prediction using a prompt to the Gemini API.

        Args:
            historical_data: A list of past data points.
            num_points: The exact number of future data points to predict.
            horizon_desc: A human-readable description of the prediction window (e.g., "1 hour").

        Returns:
            A list of floating-point numbers representing the prediction.
        """
        logger.info(f"Generating mock prediction for {num_points} points over {horizon_desc}.")

        # Create a prompt that is clear and specific for the model
        prompt = f"""
        You are a time-series forecasting model. Your task is to predict future values based on historical data.
        Please analyze the following historical data points and predict the next {num_points} values for the next {horizon_desc}.

        Historical Data:
        {json.dumps(historical_data)}

        Instructions:
        1.  Analyze the trend, seasonality, and any anomalies in the historical data.
        2.  Generate a realistic forecast for the next {num_points} data points.
        3.  Your response MUST be a JSON array of exactly {num_points} floating-point numbers. Do not include any other text, explanation, or markdown formatting.

        Example of a valid response for 4 points:
        [15.2, 16.1, 15.8, 16.5]
        """

        try:
            response = self.model.generate_content(prompt)
            # Clean up the response to ensure it's valid JSON
            cleaned_response = response.text.strip().replace("`", "").replace("json", "")
            prediction = json.loads(cleaned_response)

            if isinstance(prediction, list) and len(prediction) == num_points:
                logger.info("Successfully received and parsed mock prediction from Gemini.")
                return [float(p) for p in prediction]
            else:
                logger.error(f"Gemini response was not in the expected format. Received: {prediction}")
                # Fallback to a simple generated list if parsing fails
                return self._generate_fallback_prediction(historical_data, num_points)

        except (json.JSONDecodeError, Exception) as e:
            logger.error(f"Error calling Gemini API or parsing response: {e}", exc_info=True)
            return self._generate_fallback_prediction(historical_data, num_points)

    def _generate_fallback_prediction(self, historical_data: list, num_points: int) -> list[float]:
        """A simple fallback in case the API call fails."""
        logger.warning("Using fallback prediction logic.")
        if not historical_data:
            return [0.0] * num_points
        last_value = historical_data[-1]
        return [last_value * (1 + (i % 2) * 0.05 - 0.025) for i in range(num_points)]


# Create a singleton instance
gemini_service = GeminiPredictionService()