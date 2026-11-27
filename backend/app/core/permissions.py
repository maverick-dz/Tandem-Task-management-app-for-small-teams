# Owner: R. M only consumes this table. It must stay identical to the Flutter
# `core/permissions` table (spec F8); tests/test_permissions.py pins the contract.
import enum

from app.models.enums import Role


class Permission(str, enum.Enum):
    view_team = "view_team"
    change_own_task_status = "change_own_task_status"
    create_task = "create_task"
    assign_task = "assign_task"
    edit_task = "edit_task"
    delete_task = "delete_task"
    manage_members = "manage_members"
    manage_roles = "manage_roles"
    manage_team = "manage_team"


_MEMBER = {Permission.view_team, Permission.change_own_task_status}
_MANAGER = _MEMBER | {
    Permission.create_task,
    Permission.assign_task,
    Permission.edit_task,
    Permission.delete_task,
}
# Admin manages members and roles, and can do everything a Manager can.
_ADMIN = _MANAGER | {
    Permission.manage_members,
    Permission.manage_roles,
    Permission.manage_team,
}

ROLE_PERMISSIONS: dict[Role, frozenset[Permission]] = {
    Role.member: frozenset(_MEMBER),
    Role.manager: frozenset(_MANAGER),
    Role.admin: frozenset(_ADMIN),
}


def can(role: str | Role, permission: Permission) -> bool:
    try:
        return permission in ROLE_PERMISSIONS[Role(role)]
    except ValueError:
        return False
