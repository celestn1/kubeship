# kubeship/microservices/auth-service/alembic/versions/e806ae3d2827_create_users_profile_table.py

"""create users_profile table

Revision ID: e806ae3d2827
Revises: 
Create Date: 2025-06-05 15:00:53.458254

"""
# from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
# revision: str = 'e806ae3d2827'
# down_revision: Union[str, None] = None
# branch_labels: Union[str, Sequence[str], None] = None
# depends_on: Union[str, Sequence[str], None] = None

# revision identifiers, used by Alembic
revision = 'e806ae3d2827'
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    op.create_table(
        'users_profile',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, unique=True),
        sa.Column('avatar_url', sa.String(length=255), nullable=True),
        sa.Column('bio', sa.String(length=500), nullable=True),
        sa.Column('location', sa.String(length=100), nullable=True),
        sa.Column('website', sa.String(length=255), nullable=True),
        sa.Column('interests', sa.String(length=255), nullable=True),
        sa.Column('joined_date', sa.DateTime(), server_default=sa.func.now()),
    )

def downgrade():
    op.drop_table('users_profile')

