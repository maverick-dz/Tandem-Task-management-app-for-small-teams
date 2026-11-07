import enum


class ReminderOffset(str, enum.Enum):
    on_day = "on_day"                  # 08:00 on the day of the deadline
    one_day_before = "one_day_before"
    one_hour_before = "one_hour_before"