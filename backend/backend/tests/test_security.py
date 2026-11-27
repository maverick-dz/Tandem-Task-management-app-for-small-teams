import uuid

from app.core.security import (
    create_access_token,
    decode_access_token,
    hash_password,
    verify_password,
)


def test_password_hash_is_not_the_password_and_verifies():
    hashed = hash_password("correct horse")
    assert hashed != "correct horse"
    assert verify_password("correct horse", hashed)
    assert not verify_password("wrong", hashed)


def test_token_round_trip():
    user_id = uuid.uuid4()
    assert decode_access_token(create_access_token(user_id)) == user_id


def test_expired_and_tampered_tokens_are_rejected():
    user_id = uuid.uuid4()
    assert decode_access_token(create_access_token(user_id, minutes=-1)) is None
    token = create_access_token(user_id)
    assert decode_access_token(token[:-2] + "xx") is None
    assert decode_access_token("not-a-token") is None
