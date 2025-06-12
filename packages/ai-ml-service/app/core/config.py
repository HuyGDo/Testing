import os
from pydantic import ValidationError
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """
    Application settings.
    """
    DATABASE_URL: str
    REDIS_URL: str = "redis://localhost:6379"
    RABBITMQ_URL: str = "amqp://guest:guest@localhost:5672/%2f"
    TEST_MODE: bool = False

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "ignore"

try:
    settings = Settings()
except ValidationError as e:
    print("---")
    print("ERROR: Configuration validation failed.")
    print("This can be caused by a missing or misconfigured '.env' file.")
    # Assuming the app is run from `packages/ai-ml-service`
    expected_env_path = os.path.abspath(".env")
    print(f"Please ensure the '.env' file exists at: {expected_env_path}")
    print('And that it contains a valid DATABASE_URL, for example:')
    print('DATABASE_URL="postgresql://postgres:postgres@localhost:5432/vdt_cloud_forecast"')
    print('REDIS_URL="redis://localhost:6379"')
    print('RABBITMQ_URL="amqp://guest:guest@localhost:5672/%2f"')
    print("---\n")
    raise e
