from abc import ABC, abstractmethod
import pandas as pd

class BaseMetricTransformer(ABC):
    """
    Abstract base class for metric transformers.
    """

    @abstractmethod
    def create_features(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Create features from the input data.

        :param data: A pandas DataFrame with a 'ts' column for time and a 'value' column for the metric.
        :return: A pandas DataFrame with new features.
        """
        pass
