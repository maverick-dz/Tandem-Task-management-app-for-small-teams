import enum


class ReminderOffset(str, enum.Enum):
    on_day = "on_day"  # 08:00 on the day of the deadline
    one_day_before = "one_day_before"
    one_hour_before = "one_hour_before"


class Role(str, enum.Enum):
    admin = "admin"
    manager = "manager"
    member = "member"


class TaskStatus(str, enum.Enum):
    todo = "todo"
    in_progress = "in_progress"
    done = "done"


class Language(str, enum.Enum):
    ar = "ar"
    fr = "fr"
    en = "en"


class FeedbackKind(str, enum.Enum):
    problem = "problem"
    idea = "idea"
    other = "other"


class NotificationKind(str, enum.Enum):
    assigned = "assigned"
    due_soon = "due_soon"
    overdue = "overdue"
    task_done = "task_done"


class Platform(str, enum.Enum):
    android = "android"
    ios = "ios"
