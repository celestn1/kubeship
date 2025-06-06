"""add firstname lastname username to users

Revision ID: be0ec1012ba6
Revises: e806ae3d2827
Create Date: 2025-06-05 18:22:42.287129

"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'be0ec1012ba6'
down_revision = 'e806ae3d2827'
branch_labels = None
depends_on = None

def upgrade():
    op.add_column('users', sa.Column('firstname', sa.String(), nullable=True))
    op.add_column('users', sa.Column('lastname', sa.String(), nullable=True))
    op.add_column('users', sa.Column('username', sa.String(), nullable=True))
    op.create_unique_constraint('uq_users_username', 'users', ['username'])

def downgrade():
    op.drop_constraint('uq_users_username', 'users', type_='unique')
    op.drop_column('users', 'username')
    op.drop_column('users', 'lastname')
    op.drop_column('users', 'firstname')
