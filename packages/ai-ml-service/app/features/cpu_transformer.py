import pandas as pd
from statsmodels.tsa.seasonal import seasonal_decompose
from app.features.base_transformer import BaseMetricTransformer

class CpuMetricTransformer(BaseMetricTransformer):
    """
    Concrete transformer for CPU metrics.
    """

    def create_features(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Decomposes the CPU utilization time series into trend, seasonal, and residual components.

        :param data: A pandas DataFrame with 'ts' and 'value' columns.
        :return: A pandas DataFrame with 'trend', 'seasonal', and 'resid' columns.
        """
        if not isinstance(data.index, pd.DatetimeIndex):
            data['ts'] = pd.to_datetime(data['ts'])
            data = data.set_index('ts')

        # Decompose the time series. The period is set to 24 (assuming hourly data for a daily seasonality)
        # This might need to be adjusted based on the actual data frequency.
        decomposition = seasonal_decompose(data['value'], model='additive', period=24)

        features = pd.DataFrame({
            'trend': decomposition.trend,
            'seasonal': decomposition.seasonal,
            'resid': decomposition.resid
        })

        return features.dropna()
