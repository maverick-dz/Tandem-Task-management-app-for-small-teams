import enum
from typing import Any

from fastapi import FastAPI, Request
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse


class ErrorCode(str, enum.Enum):
    """Stable codes the app maps to translated messages (never English text)."""

    UNAUTHENTICATED = "UNAUTHENTICATED"
    INVALID_CREDENTIALS = "INVALID_CREDENTIALS"
    FORBIDDEN = "FORBIDDEN"
    NOT_FOUND = "NOT_FOUND"
    VALIDATION_ERROR = "VALIDATION_ERROR"
    EMAIL_TAKEN = "EMAIL_TAKEN"
    LAST_ADMIN = "LAST_ADMIN"
    TASK_NOT_FOUND = "TASK_NOT_FOUND"
    NOT_ASSIGNEE = "NOT_ASSIGNEE"
    TASK_CONFLICT = "TASK_CONFLICT"
    PLAN_REQUIRED = "PLAN_REQUIRED"


class AppError(Exception):
    def __init__(
        self,
        code: ErrorCode,
        status_code: int,
        message: str | None = None,
        detail: dict[str, Any] | None = None,
    ) -> None:
        super().__init__(message or code.value)
        self.code = code
        self.status_code = status_code
        self.message = message or code.value
        self.detail = detail or {}


def unauthenticated() -> AppError:
    return AppError(ErrorCode.UNAUTHENTICATED, 401, "Sign in to continue.")


def forbidden(code: ErrorCode = ErrorCode.FORBIDDEN, message: str = "Not allowed.") -> AppError:
    return AppError(code, 403, message)


def not_found(code: ErrorCode = ErrorCode.NOT_FOUND, message: str = "Not found.") -> AppError:
    return AppError(code, 404, message)


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(AppError)
    async def _app_error(_: Request, exc: AppError) -> JSONResponse:
        body = {"code": exc.code.value, "message": exc.message, "detail": exc.detail}
        return JSONResponse(status_code=exc.status_code, content=jsonable_encoder(body))

    @app.exception_handler(RequestValidationError)
    async def _validation_error(_: Request, exc: RequestValidationError) -> JSONResponse:
        errors = [
            {"loc": list(e.get("loc", ())), "msg": e.get("msg", ""), "type": e.get("type", "")}
            for e in exc.errors()
        ]
        body = {
            "code": ErrorCode.VALIDATION_ERROR.value,
            "message": "Invalid request.",
            "detail": {"errors": errors},
        }
        return JSONResponse(status_code=422, content=jsonable_encoder(body))
