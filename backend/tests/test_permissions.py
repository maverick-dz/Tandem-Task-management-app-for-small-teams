import pytest

from app.core.permissions import ROLE_PERMISSIONS, Permission, can
from app.models.enums import Role

# Spec F8, written out once more on purpose: if this table and the code ever
# disagree, the Flutter permission table (R) must be checked too.
EXPECTED = {
    Role.member: {Permission.view_team, Permission.change_own_task_status},
    Role.manager: {
        Permission.view_team,
        Permission.change_own_task_status,
        Permission.create_task,
        Permission.assign_task,
        Permission.edit_task,
        Permission.delete_task,
    },
    Role.admin: set(Permission),
}


@pytest.mark.parametrize("role", list(Role))
def test_each_role_has_exactly_the_spec_permissions(role):
    assert set(ROLE_PERMISSIONS[role]) == EXPECTED[role]


def test_member_cannot_create_or_assign_tasks_or_change_roles():
    for permission in (Permission.create_task, Permission.assign_task, Permission.manage_roles):
        assert not can(Role.member, permission)


def test_manager_creates_and_assigns_but_does_not_manage_roles():
    assert can(Role.manager, Permission.create_task)
    assert can(Role.manager, Permission.assign_task)
    assert not can(Role.manager, Permission.manage_roles)
    assert not can(Role.manager, Permission.manage_members)


def test_admin_can_do_everything_a_manager_can():
    assert ROLE_PERMISSIONS[Role.manager] <= ROLE_PERMISSIONS[Role.admin]
    assert can(Role.admin, Permission.manage_roles)


def test_role_may_be_given_as_text_and_unknown_roles_get_nothing():
    assert can("manager", Permission.create_task)
    assert not can("owner", Permission.view_team)
