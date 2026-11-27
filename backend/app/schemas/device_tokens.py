from pydantic import BaseModel, Field

from app.models.enums import Platform


class DeviceTokenIn(BaseModel):
    token: str = Field(min_length=8, max_length=512)
    platform: Platform


class DeviceTokenDelete(BaseModel):
    token: str = Field(min_length=8, max_length=512)
