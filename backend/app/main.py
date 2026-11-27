from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api.v1 import device_tokens, feedback, sync, task_status, users
from app.core.config import settings
from app.core.errors import register_error_handlers
from app.workers.scheduler import register_jobs, scheduler


@asynccontextmanager
async def lifespan(_: FastAPI):
    # Only one instance may run the scheduler, or every reminder is sent twice.
    if settings.run_scheduler:
        register_jobs()
        scheduler.start()
    yield
    if scheduler.running:
        scheduler.shutdown(wait=False)


app = FastAPI(title="Tandem API", version="0.1.0", lifespan=lifespan)
register_error_handlers(app)


@app.get("/health", tags=["health"])
async def health() -> dict[str, str]:
    """Used by the host's health check and by the free-tier keep-alive ping."""
    return {"status": "ok"}


# One line per router. Each owner adds theirs here (R: auth, teams, notifications;
# N: tasks).
for module in (users, feedback, task_status, device_tokens, sync):
    app.include_router(module.router, prefix="/api/v1")
