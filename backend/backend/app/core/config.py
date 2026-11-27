from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Neon: the pooled URL (-pooler host) for the app ...
    database_url: str
    # ... and the direct URL for migrations. Falls back to the pooled URL.
    database_url_direct: str | None = None

    jwt_secret: str
    jwt_algorithm: str = "HS256"
    access_token_minutes: int = 60 * 24

    # true only on the one instance that should send reminders
    run_scheduler: bool = False
    app_timezone: str = "Africa/Algiers"

    # Push (Firebase Cloud Messaging). Without credentials push is a no-op and
    # the in-app Alerts list still works.
    firebase_credentials_path: str | None = None

    # Version of the privacy policy a person consents to (screen 054).
    policy_version: str = "2026-11"

    @property
    def migrations_url(self) -> str:
        return self.database_url_direct or self.database_url


settings = Settings()
