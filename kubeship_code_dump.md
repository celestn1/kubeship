===== ./.gitignore =====
# kubeship/.gitignore

# === Terraform ===
*.tfstate
*.tfstate.backup
*.tfvars
*.tfplan
crash.log
.terraform/
.terraform.lock.hcl

# === Node.js ===
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
logs/
*.log

# === Python ===
*.pyc
__pycache__/
*.pyo
*.pyd
.venv/
env/
venv/

# === Environment Files ===
.env
.env.*
.env.local
.env.*.local
secrets.auto.tfvars

# === Build Outputs ===
dist/
build/
coverage/
pids/
*.pid
*.seed

# === VSCode & IDEs ===
.vscode/
.idea/
*.suo
*.ntvs*
*.njsproj
*.sln

# === OS-specific Files ===
.DS_Store
Thumbs.db

# === GitHub Actions ===
.github/workflows/*.log

# === Optional: Certificates / Private Keys ===
*.pem

# === Testing Artifacts ===
.test/
*export_code.sh
*kubeship_code_dump



===== ./docker-compose.yml =====
# kubeship/docker-compose.yml

services:
  nginx-gateway:
    build:
      context: ./nginx
    ports:
      - "3000:80"
    depends_on:
      - auth-service

  auth-service:
    build: ./microservices/auth-service
    environment:
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      - kubeship-pg-db

  kubeship-pg-db:
    image: postgres:latest
    container_name: kubeship-pg-db
    restart: always
    environment:
      POSTGRES_DB: auth_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password123
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  pgdata:




===== ./export_code.sh =====
#!/bin/bash

# Output file
OUTPUT_FILE="kubeship_code_dump.md"

# Start fresh
> "$OUTPUT_FILE"

# Run find command scoped to auth-service and frontend only
find . -type f \
  ! -path "*/__pycache__/*" \
  ! -path "*/node_modules/*" \
  ! -path "*/.venv/*" \
  ! -path "*/env/*" \
  ! -path "*/venv/*" \
  ! -path "*/dist/*" \
  ! -path "*/build/*" \
  ! -path "*/coverage/*" \
  ! -path "./.git/*" \
  ! -path "./.github/*" \
  ! -path "./.vscode/*" \
  ! -path "./.idea/*" \
  ! -path "./terraform/*" \
  ! -name "*.pyc" \
  ! -name "*.pyo" \
  ! -name "*.pyd" \
  ! -name "*.log" \
  ! -name "*.tfstate" \
  ! -name "*.tfstate.backup" \
  ! -name "*.tfvars" \
  ! -name "*.tfplan" \
  ! -name "*.pid" \
  ! -name "*.suo" \
  ! -name "*.ntvs*" \
  ! -name "*.njsproj" \
  ! -name "*.sln" \
  ! -name "*.env" \
  ! -name ".env.*" \
  ! -name "*.pem" \
  ! -name ".DS_Store" \
  ! -name "Thumbs.db" \
  ! -name "secrets.auto.tfvars" \
  ! -path "*/.github/workflows/*.log" \
  ! \( -name "package-lock.json" -o -name "package*.json" ! -name "package.json" \) \
  -exec sh -c 'echo "===== $1 ====="; cat "$1"; echo "\n\n\n"' _ {} \; >> "$OUTPUT_FILE"

echo "✅ Export completed: $OUTPUT_FILE"





===== ./helm-charts/api-gateway/Chart.yaml =====
apiVersion: v2
name: api-gateway
description: KubeShip API Gateway Helm Chart
type: application
version: 0.1.0
appVersion: "1.0.0"





===== ./helm-charts/api-gateway/templates/deployment.yaml =====
# kubeship/helm-charts/api-gateway/templates/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name }}
  labels:
    app: {{ .Chart.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
          env:
            {{- range .Values.env }}
            - name: {{ .name }}
              value: {{ .value | quote }}
            {{- end }}




===== ./helm-charts/api-gateway/templates/service.yaml =====
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}-service
spec:
  selector:
    app: {{ .Chart.Name }}
  ports:
    - protocol: TCP
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
  type: {{ .Values.service.type }}




===== ./helm-charts/api-gateway/values.yaml =====
replicaCount: 1

image:
  repository: api-gateway
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 8000

env:
  - name: LOG_LEVEL
    value: "info"




===== ./kubeship_code_dump.md =====




===== ./manifests/api-gateway-app.yaml =====
# kubeship/manifests/api-gateway-app.yaml

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: api-gateway
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/celestn1/kubeship
    targetRevision: HEAD
    path: helm-charts/api-gateway
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true




===== ./manifests/project.yaml =====
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: kubeship-project



===== ./microservices/auth-service/alembic/env.py =====
import os
from logging.config import fileConfig

from sqlalchemy import create_engine, pool
from alembic import context

# Load environment variable
from dotenv import load_dotenv
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

# Alembic Config object
config = context.config

# Load logging configuration
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Target metadata for autogenerate (update this if using models)
from app.db import Base
target_metadata = Base.metadata

# Get database URL
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise Exception("DATABASE_URL environment variable is not set.")

def run_migrations_offline() -> None:
    """Run migrations in offline mode."""
    context.configure(
        url=DATABASE_URL,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Run migrations in online mode."""
    connectable = create_engine(DATABASE_URL, poolclass=pool.NullPool)

    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()




===== ./microservices/auth-service/alembic/README =====
Generic single-database configuration.



===== ./microservices/auth-service/alembic/script.py.mako =====
"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
${imports if imports else ""}

# revision identifiers, used by Alembic.
revision: str = ${repr(up_revision)}
down_revision: Union[str, None] = ${repr(down_revision)}
branch_labels: Union[str, Sequence[str], None] = ${repr(branch_labels)}
depends_on: Union[str, Sequence[str], None] = ${repr(depends_on)}


def upgrade() -> None:
    """Upgrade schema."""
    ${upgrades if upgrades else "pass"}


def downgrade() -> None:
    """Downgrade schema."""
    ${downgrades if downgrades else "pass"}




===== ./microservices/auth-service/alembic/versions/be0ec1012ba6_add_firstname_lastname_username_to_users.py =====
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




===== ./microservices/auth-service/alembic/versions/e806ae3d2827_create_users_profile_table.py =====
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





===== ./microservices/auth-service/alembic.ini =====
# A generic, single database configuration.

[alembic]
# path to migration scripts.
# this is typically a path given in POSIX (e.g. forward slashes)
# format, relative to the token %(here)s which refers to the location of this
# ini file
script_location = %(here)s/alembic

# template used to generate migration file names; The default value is %%(rev)s_%%(slug)s
# Uncomment the line below if you want the files to be prepended with date and time
# see https://alembic.sqlalchemy.org/en/latest/tutorial.html#editing-the-ini-file
# for all available tokens
# file_template = %%(year)d_%%(month).2d_%%(day).2d_%%(hour).2d%%(minute).2d-%%(rev)s_%%(slug)s

# sys.path path, will be prepended to sys.path if present.
# defaults to the current working directory.  for multiple paths, the path separator
# is defined by "path_separator" below.
prepend_sys_path = .


# timezone to use when rendering the date within the migration file
# as well as the filename.
# If specified, requires the python>=3.9 or backports.zoneinfo library and tzdata library.
# Any required deps can installed by adding `alembic[tz]` to the pip requirements
# string value is passed to ZoneInfo()
# leave blank for localtime
# timezone =

# max length of characters to apply to the "slug" field
# truncate_slug_length = 40

# set to 'true' to run the environment during
# the 'revision' command, regardless of autogenerate
# revision_environment = false

# set to 'true' to allow .pyc and .pyo files without
# a source .py file to be detected as revisions in the
# versions/ directory
# sourceless = false

# version location specification; This defaults
# to <script_location>/versions.  When using multiple version
# directories, initial revisions must be specified with --version-path.
# The path separator used here should be the separator specified by "path_separator"
# below.
# version_locations = %(here)s/bar:%(here)s/bat:%(here)s/alembic/versions

# path_separator; This indicates what character is used to split lists of file
# paths, including version_locations and prepend_sys_path within configparser
# files such as alembic.ini.
# The default rendered in new alembic.ini files is "os", which uses os.pathsep
# to provide os-dependent path splitting.
#
# Note that in order to support legacy alembic.ini files, this default does NOT
# take place if path_separator is not present in alembic.ini.  If this
# option is omitted entirely, fallback logic is as follows:
#
# 1. Parsing of the version_locations option falls back to using the legacy
#    "version_path_separator" key, which if absent then falls back to the legacy
#    behavior of splitting on spaces and/or commas.
# 2. Parsing of the prepend_sys_path option falls back to the legacy
#    behavior of splitting on spaces, commas, or colons.
#
# Valid values for path_separator are:
#
# path_separator = :
# path_separator = ;
# path_separator = space
# path_separator = newline
#
# Use os.pathsep. Default configuration used for new projects.
path_separator = os

# set to 'true' to search source files recursively
# in each "version_locations" directory
# new in Alembic version 1.10
# recursive_version_locations = false

# the output encoding used when revision files
# are written from script.py.mako
# output_encoding = utf-8

# database URL.  This is consumed by the user-maintained env.py script only.
# other means of configuring database URLs may be customized within the env.py
# file.
sqlalchemy.url = driver://user:pass@localhost/dbname


[post_write_hooks]
# post_write_hooks defines scripts or Python functions that are run
# on newly generated revision scripts.  See the documentation for further
# detail and examples

# format using "black" - use the console_scripts runner, against the "black" entrypoint
# hooks = black
# black.type = console_scripts
# black.entrypoint = black
# black.options = -l 79 REVISION_SCRIPT_FILENAME

# lint with attempts to fix using "ruff" - use the exec runner, execute a binary
# hooks = ruff
# ruff.type = exec
# ruff.executable = %(here)s/.venv/bin/ruff
# ruff.options = check --fix REVISION_SCRIPT_FILENAME

# Logging configuration.  This is also consumed by the user-maintained
# env.py script only.
[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARNING
handlers = console
qualname =

[logger_sqlalchemy]
level = WARNING
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S




===== ./microservices/auth-service/app/db.py =====
# kubeship/microservices/auth-service/app/db.py

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from databases import Database

# Load .env file
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL is not set. Please check your .env file.")

# SQLAlchemy components
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Async database connection (optional if using FastAPI)
database = Database(DATABASE_URL)



===== ./microservices/auth-service/app/dependencies.py =====
# kubeship/microservices/auth-service/app/dependencies.py

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from app.db import SessionLocal
from app.models.user import User

SECRET_KEY = "kubeship_secret"
ALGORITHM = "HS256"

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if not username:
            raise HTTPException(status_code=401, detail="Invalid token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

    user = db.query(User).filter(User.email == username).first()
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")

    return user




===== ./microservices/auth-service/app/main.py =====
# kubeship/microservices/auth-service/app/main.py

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError

from app.db import database, engine, Base
from app.routers import auth, profile
from app.utils import error_handler

app = FastAPI(title="KubeShip Auth Service with PostgreSQL")

# CORS – Replace * with specific origin in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Error handlers
app.add_exception_handler(HTTPException, error_handler.http_exception_handler)
app.add_exception_handler(RequestValidationError, error_handler.validation_exception_handler)

# Database startup/shutdown
@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)
    await database.connect()

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()

# Versioned routes under /v1/auth/
auth_router = FastAPI()
auth_router.include_router(auth.router, prefix="/auth")
auth_router.include_router(profile.router, prefix="/profile")
app.mount("/v1", auth_router)

# Health/root check
@app.get("/")
def root():
    return {"message": "Auth service with PostgreSQL is running"}




===== ./microservices/auth-service/app/models/user.py =====
# kubeship/microservices/auth-service/app/models/user.py

from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db import Base
from datetime import datetime

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True)
    username = Column(String, unique=True)
    hashed_password = Column(String)
    firstname = Column(String)
    lastname = Column(String)

    profile = relationship("UserProfile", uselist=False, back_populates="user")


class UserProfile(Base):
    __tablename__ = "users_profile"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    avatar_url = Column(String, nullable=True)
    bio = Column(String, nullable=True)
    location = Column(String, nullable=True)
    website = Column(String, nullable=True)
    skills = Column(String, nullable=True)
    date_joined = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="profile")




===== ./microservices/auth-service/app/models/user_profile.py =====
# kubeship/microservices/auth-service/app/models/user_profile.py

from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db import Base

class UserProfile(Base):
    __tablename__ = "users_profile"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    avatar_url = Column(String, nullable=True)
    bio = Column(String, nullable=True)
    location = Column(String, nullable=True)
    website = Column(String, nullable=True)
    interests = Column(String, nullable=True)  # Stored as CSV or JSON
    joined_date = Column(DateTime(timezone=True), server_default=func.now())




===== ./microservices/auth-service/app/routers/auth.py =====
# kubeship/microservices/auth-service/app/routers/auth.py

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from sqlalchemy import or_
from passlib.context import CryptContext
from datetime import datetime, timedelta
from typing import Optional
import jwt

from app.db import SessionLocal
from app.models.user import User as UserModel

router = APIRouter()

SECRET_KEY = "kubeship_secret"
ALGORITHM = "HS256"
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class LoginRequest(BaseModel):
    username: str
    password: str

class UserRegister(BaseModel):
    firstname: str
    lastname: str
    email: EmailStr
    username: str
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/check")
def check_availability(email: str = None, username: str = None, db: Session = Depends(get_db)):
    if email:
        exists = db.query(UserModel).filter(UserModel.email == email).first()
        if exists:
            return {"available": False, "field": "email"}

    if username:
        exists = db.query(UserModel).filter(UserModel.username == username).first()
        if exists:
            return {"available": False, "field": "username"}

    return {"available": True}


@router.post("/register")
def register(user: UserRegister, db: Session = Depends(get_db)):
    # Check for existing email or username
    existing = db.query(UserModel).filter(
        (UserModel.email == user.email) | (UserModel.username == user.username)
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email or username already exists")

    hashed_pw = pwd_context.hash(user.password)

    db_user = UserModel(
        email=user.email,
        username=user.username,
        hashed_password=hashed_pw,
        firstname=user.firstname,
        lastname=user.lastname,
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return {"message": "User registered successfully"}


@router.post("/login", response_model=Token)
def login(user: LoginRequest, db: Session = Depends(get_db)):
    db_user = db.query(UserModel).filter(
        or_(
            UserModel.email == user.username,
            UserModel.username == user.username
        )
    ).first()
    if not db_user or not pwd_context.verify(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token({
        "sub": db_user.email,
        "firstname": db_user.firstname
    }, expires_delta=timedelta(hours=1))
    return {"access_token": token, "token_type": "bearer"}


@router.get("/verify")
def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return {
            "valid": True,
            "email": payload.get("sub"),
            "firstname": payload.get("firstname")
        }
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")




===== ./microservices/auth-service/app/routers/profile.py =====
# kubeship/microservices/auth-service/app/routers/profile.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.dependencies import get_current_user, get_db
from app.models.user import User, UserProfile

router = APIRouter()

class UpdateProfileRequest(BaseModel):
    avatar_url: str | None = None
    bio: str | None = None
    location: str | None = None
    website: str | None = None
    skills: str | None = None

@router.get("/profile")
def get_profile(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return current_user.profile

@router.put("/profile")
def update_profile(payload: UpdateProfileRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    profile = current_user.profile
    for field, value in payload.dict(exclude_unset=True).items():
        setattr(profile, field, value)
    db.commit()
    db.refresh(profile)
    return {"message": "Profile updated successfully ✅"}




===== ./microservices/auth-service/app/utils/error_handler.py =====
# ======================================
# Backend: FastAPI Centralized Handlers
# File: auth-service/app/utils/error_handler.py
# ======================================

from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.status import HTTP_422_UNPROCESSABLE_ENTITY

async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})

async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": "Validation failed", "errors": exc.errors()}
    )




===== ./microservices/auth-service/app/utils/security.py =====
# kubeship/microservices/auth-service/app/utils/security.py

from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)




===== ./microservices/auth-service/Dockerfile =====
# kubeship/microservices/auth-service/Dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./app ./app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]



===== ./microservices/auth-service/requirements.txt =====
fastapi
uvicorn[standard]
pydantic
python-jose
pyjwt
sqlalchemy
databases
asyncpg
passlib[bcrypt]
psycopg2-binary
pydantic[email]
bcrypt==4.1.2



===== ./microservices/frontend/Dockerfile =====
FROM node:18-alpine

WORKDIR /app
COPY . .

RUN npm install
RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "preview"]




===== ./microservices/frontend/index.html =====
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>KubeShip Frontend</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>



===== ./microservices/frontend/package.json =====
{
  "name": "kubeship-frontend",
  "version": "0.1.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^7.6.2"
  },
  "devDependencies": {
    "@types/node": "^22.15.29",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "@vitejs/plugin-react": "^4.0.0",
    "autoprefixer": "^10.4.21",
    "postcss": "^8.5.4",
    "tailwindcss": "^3.4.17",
    "typescript": "^4.6.0",
    "vite": "^6.3.5"
  }
}




===== ./microservices/frontend/postcss.config.js =====
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}




===== ./microservices/frontend/src/apiClient.ts =====
// kubeship/microservices/frontend/src/apiClient.ts

import { getErrorMessage, extractStatusCode } from "./errorHandler";

const BASE_URL = import.meta.env.VITE_API_URL;

export async function register(username: string, password: string) {
  try {
    const res = await fetch(`${import.meta.env.VITE_API_URL}/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });

    const data = await res.json();

    return {
      message: data.message || data.detail || "Registration failed",
      success: res.ok,
    };
  } catch (err) {
    return {
      message: "Network error during registration",
      success: false,
    };
  }
}

export const login = async (username: string, password: string) => {
  try {
    const response = await fetch(`${import.meta.env.VITE_API_URL}/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });

    const data = await response.json();

    return response.ok
      ? { token: data.access_token, message: "Login successful" }
      : { token: null, message: data.detail || "Login failed" };
  } catch {
    return {
      token: null,
      message: "Network error during login",
    };
  }
};





===== ./microservices/frontend/src/App.tsx =====
import React from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import Login from "./pages/Login";
import Register from "./pages/Register";
import Dashboard from "./pages/Dashboard";
import Profile from "./pages/Profile";
import Layout from "./components/Layout";
import RequireAuth from "./components/RequireAuth";

function App() {
  return (
    <Routes>
      {/* Public Routes */}
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />

      {/* Protected Routes with layout */}
      <Route element={<Layout />}>
        <Route
          path="/"
          element={
            <RequireAuth>
              <Dashboard />
            </RequireAuth>
          }
        />
        <Route
          path="/profile"
          element={
            <RequireAuth>
              <Profile />
            </RequireAuth>
          }
        />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Route>
    </Routes>
  );
}

export default App;




===== ./microservices/frontend/src/components/AvatarUpload.tsx =====
// kubeship/microservices/frontend/src/components/AvatarUpload.tsx

import React, { useState } from "react";

interface AvatarUploadProps {
  onFileSelect: (file: File) => void;
  previewUrl?: string;
}

const AvatarUpload: React.FC<AvatarUploadProps> = ({ onFileSelect, previewUrl }) => {
  const [preview, setPreview] = useState(previewUrl || "");

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setPreview(URL.createObjectURL(file));
      onFileSelect(file);
    }
  };

  return (
    <div className="text-center mb-4">
      <div className="w-24 h-24 mx-auto rounded-full overflow-hidden border">
        <img
          src={preview || "/default-avatar.png"}
          alt="User avatar"
          className="w-full h-full object-cover"
        />
      </div>
      <input type="file" className="mt-2" onChange={handleChange} />
    </div>
  );
};

export default AvatarUpload;




===== ./microservices/frontend/src/components/Button.tsx =====
// kubeship/microservices/frontend/src/components/Button.tsx
import React from "react";

interface ButtonProps {
  label: string;
  onClick: () => void;
  color?: "green" | "blue" | "red";
}

const Button: React.FC<ButtonProps> = ({ label, onClick, color = "blue" }) => {
  const base = "text-white px-4 py-2 rounded";
  const colors = {
    green: "bg-green-500 hover:bg-green-600",
    blue: "bg-blue-500 hover:bg-blue-600",
    red: "bg-red-500 hover:bg-red-600",
  };
  return (
    <button onClick={onClick} className={`${colors[color]} ${base}`}>
      {label}
    </button>
  );
};

export default Button;



===== ./microservices/frontend/src/components/Card.tsx =====
// kubeship/microservices/frontend/src/components/Card.tsx
import React from "react";

const Card: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div className="bg-white shadow-md rounded p-6 w-full max-w-md text-center">
    {children}
  </div>
);

export default Card;



===== ./microservices/frontend/src/components/Input.tsx =====
// kubeship/microservices/frontend/src/components/Input.tsx
import React from "react";

interface InputProps {
  type: string;
  placeholder: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

const Input: React.FC<InputProps> = ({ type, placeholder, value, onChange }) => (
  <input
    type={type}
    placeholder={placeholder}
    className="w-full mb-3 p-2 border rounded"
    value={value}
    onChange={onChange}
  />
);

export default Input;



===== ./microservices/frontend/src/components/Layout.tsx =====
// kubeship/microservices/frontend/src/components/Layout.tsx

import React, { useEffect, useState, useRef } from "react";
import { Outlet, Link, useNavigate, useLocation } from "react-router-dom";
import { login } from "../apiClient";
import toast from "react-hot-toast";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

export type LayoutContextType = {
  verifiedUser: string | null;
  handleLogout: () => void;
};

const Layout = () => {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [token, setToken] = useState<string | null>(localStorage.getItem("token"));
  const [verifiedUser, setVerifiedUser] = useState<string | null>(null);
  const hasShownToast = useRef(false);
  const navigate = useNavigate();
  const location = useLocation();
  

  const handleLogin = async () => {
    const result = await login(username, password);
    if (result.token) {
      setMessage("Login successful");
      localStorage.setItem("token", result.token);
      setToken(result.token);
    } else {
      setMessage(result.message || "Login failed");
    }
  };

  const handleLogout = () => {
    localStorage.removeItem("token");
    setToken(null);
    setVerifiedUser(null);
    setUsername("");
    setPassword("");
    setMessage("Logged Out Successfully");
    navigate("/");
  };

  useEffect(() => {
    if (location.state?.flash && !hasShownToast.current) {
        toast.success(location.state.flash);
        hasShownToast.current = true;
        navigate(location.pathname, { replace: true, state: {} });
    }
  }, [location]);
  
  
  useEffect(() => {
    const verifyToken = async () => {
      if (!token) return;
      try {
        const res = await fetch(`${API_URL}/auth/verify?token=${token}`);
        const json = await res.json();
        if (json.valid) {
          setVerifiedUser(json.firstname);
        } else {
          setToken(null);
        }
      } catch (err) {
        console.error("Token verification failed:", err);
        setToken(null);
      }
    };
    verifyToken();
  }, [token]);

  return !token ? (
    <div className="flex items-center justify-center min-h-screen bg-gray-100 p-4">
      <div className="bg-white shadow-md rounded p-6 w-full max-w-md mx-auto">
        <h1 className="text-3xl font-bold text-center text-blue-600 mb-6">
          🚢 KubeShip Frontend
        </h1>

        <input
          type="text"
          placeholder="Email or username"
          className="w-full mb-3 p-2 border rounded"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
        />
        <input
          type="password"
          placeholder="Password"
          className="w-full mb-3 p-2 border rounded"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button
          onClick={handleLogin}
          className="w-full bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded"
        >
          Login
        </button>

        <p className="mt-4 text-sm text-center text-gray-700">
          Don’t have an account?{" "}
          <a href="/register" className="text-blue-600 underline">Sign up</a>
        </p>

        {message && <p className="mt-2 text-sm text-center text-red-600">{message}</p>}
      </div>
    </div>
  ) : (
    <div className="min-h-screen bg-gray-100 p-4">
      <header className="bg-white shadow p-4 mb-6">
        <Link to="/" className="text-2xl font-bold text-blue-600 pl-4 hover:underline">
          🚢 KubeShip Frontend
        </Link>
      </header>
      <nav className="flex justify-center space-x-4 mb-6">
        <Link to="/" className="text-blue-600 hover:underline">
          Dashboard
        </Link>
        <Link to="/profile" className="text-blue-600 hover:underline">
          Profile
        </Link>
        <button
          onClick={handleLogout}
          className="text-red-600 hover:underline"
        >
          Logout
        </button>
      </nav>
      <Outlet context={{ verifiedUser, handleLogout }} />
    </div>
  );
};

export default Layout;




===== ./microservices/frontend/src/components/ProfileEditForm.tsx =====
// kubeship/microservices/frontend/src/components/ProfileEditForm.tsx

import React, { useState } from "react";

interface Props {
  initialBio: string;
  onSave: (bio: string, avatar: File | null) => void;
  onCancel: () => void;
}

const ProfileEditForm: React.FC<Props> = ({ initialBio, onSave, onCancel }) => {
  const [bio, setBio] = useState(initialBio);
  const [avatar, setAvatar] = useState<File | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(bio, avatar);
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white shadow rounded p-6 w-full max-w-xl mx-auto">
      <div className="mb-4">
        <label className="block text-sm font-semibold mb-1">Bio</label>
        <textarea
          value={bio}
          onChange={(e) => setBio(e.target.value)}
          className="w-full border rounded p-2"
          rows={3}
        />
      </div>

      <div className="mb-4">
        <label className="block text-sm font-semibold mb-1">Upload Avatar</label>
        <input type="file" onChange={(e) => setAvatar(e.target.files?.[0] || null)} />
      </div>

      <div className="flex justify-end space-x-3">
        <button type="button" onClick={onCancel} className="text-gray-600 hover:underline">Cancel</button>
        <button type="submit" className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600">
          Save
        </button>
      </div>
    </form>
  );
};

export default ProfileEditForm;




===== ./microservices/frontend/src/components/ProfileView.tsx =====
// kubeship/microservices/frontend/src/components/ProfileView.tsx

import React from "react";

interface Props {
  user: string;
  email: string;
  bio: string;
  joined: string;
  onEdit: () => void;
}

const ProfileView: React.FC<Props> = ({ user, email, bio, joined, onEdit }) => (
  <div className="bg-white shadow rounded p-6 w-full max-w-xl mx-auto">
    <div className="text-center mb-4">
      <h2 className="text-xl font-bold">{user}</h2>
      <p className="text-sm text-gray-600">{bio || "No bio provided."}</p>
    </div>
    <div className="text-sm text-gray-700 space-y-2">
      <div><strong>Email:</strong> {email}</div>
      <div><strong>Member since:</strong> {joined}</div>
    </div>
    <div className="text-right mt-4">
      <button onClick={onEdit} className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
        Edit Profile
      </button>
    </div>
  </div>
);

export default ProfileView;




===== ./microservices/frontend/src/components/ProtectedRoute.tsx =====
// //kubeship/microservices/frontend/src/components/ProtectedRoute.tsx

import React from "react";
import { Navigate } from "react-router-dom";

interface ProtectedRouteProps {
  isAuthenticated: boolean;
  children: React.ReactElement;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ isAuthenticated, children }) => {
  return isAuthenticated ? children : <Navigate to="/" replace />;
};

export default ProtectedRoute;




===== ./microservices/frontend/src/components/RequireAuth.tsx =====
// kubeship/microservices/frontend/src/components/RequireAuth.tsx

import React from "react";
import { Navigate, useLocation, useOutletContext } from "react-router-dom";

type ContextType = { verifiedUser: string | null };

const RequireAuth = ({ children }: { children: JSX.Element }) => {
  const location = useLocation();
  const { verifiedUser } = useOutletContext<ContextType>();

  if (!verifiedUser) {
    return <Navigate to="/" state={{ from: location }} replace />;
  }

  return children;
};

export default RequireAuth;




===== ./microservices/frontend/src/errorHandler.ts =====
// kubeship/microservices/frontend/src/errorHandler.ts

export function getErrorMessage(statusCode: number): string {
  switch (statusCode) {
    case 400:
      return "Bad request — Please check your input.";
    case 401:
      return "Unauthorized — Invalid credentials.";
    case 403:
      return "Forbidden — You don’t have permission.";
    case 404:
      return "Not found — The requested resource was not found.";
    case 500:
      return "Server error — Please try again later.";
    default:
      return "An unexpected error occurred.";
  }
}

export function extractStatusCode(err: unknown): number | undefined {
  if (typeof err === "object" && err !== null && "status" in err) {
    const status = (err as { status?: unknown }).status;
    return typeof status === "number" ? status : undefined;
  }
  return undefined;
}




===== ./microservices/frontend/src/index.css =====
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  font-family: Arial, sans-serif;
  margin: 0;
  padding: 0;
  background: #f5f7fa;
  color: #333;
}



===== ./microservices/frontend/src/main.tsx =====
// kubeship/microservices/frontend/src/main.tsx

import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";
import "./index.css";
import { Toaster } from "react-hot-toast";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <BrowserRouter>
      <Toaster position="top-center" />
      <App />
    </BrowserRouter>
  </React.StrictMode>
);




===== ./microservices/frontend/src/pages/Dashboard.tsx =====
// kubeship/microservices/frontend/src/pages/Dashboard.tsx

import React from "react";
import { useOutletContext } from "react-router-dom";
import Card from "../components/Card";
import Button from "../components/Button";
import { LayoutContextType } from "../components/Layout";

const Dashboard: React.FC = () => {
  const { verifiedUser, handleLogout } = useOutletContext<LayoutContextType>();

  return (
    <Card>
      <div className="text-center">
        <h2 className="text-xl font-semibold mb-2">
          Welcome{verifiedUser ? `, ${verifiedUser}` : ""}!
        </h2>
        <p className="text-sm text-gray-600 mb-4">You are logged in and verified ✅</p>
        <Button label="Logout" onClick={handleLogout} color="red" />
      </div>
    </Card>
  );
};

export default Dashboard;



===== ./microservices/frontend/src/pages/Login.tsx =====
// kubeship/microservices/frontend/src/pages/Login.tsx

import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import { login } from "../apiClient";

const Login: React.FC = () => {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");
    setLoading(true);

    const result = await login(username, password);

    setLoading(false);

    if (result.token) {
      toast.success("Login successful");
      localStorage.setItem("token", result.token);

      // ✅ Redirect to dashboard
      navigate("/dashboard");
    } else {
      setMessage(result.message);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-6">
      <form
        onSubmit={handleSubmit}
        className="bg-white p-8 rounded shadow-md w-full max-w-md"
      >
        <h2 className="text-2xl font-bold mb-6 text-center text-blue-700">
          🚢 KubeShip Frontend
        </h2>

        <input
          type="text"
          placeholder="Username"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          required
          className="w-full p-2 mb-4 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
        />

        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          className="w-full p-2 mb-4 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
        />

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded font-semibold disabled:opacity-50"
        >
          {loading ? "Logging in..." : "Login"}
        </button>

        <p className="mt-4 text-center text-sm">
          Don’t have an account?{" "}
          <a href="/register" className="text-blue-700 underline">
            Sign up
          </a>
        </p>

        {message && (
          <p className="mt-2 text-center text-sm text-red-600">{message}</p>
        )}
      </form>
    </div>
  );
};

export default Login;




===== ./microservices/frontend/src/pages/Profile.tsx =====
// kubeship/microservices/frontend/src/pages/Profile.tsx

import React, { useState } from "react";
import { useOutletContext } from "react-router-dom";
import AvatarUpload from "../components/AvatarUpload";
import ProfileView from "../components/ProfileView";
import ProfileEditForm from "../components/ProfileEditForm";

const Profile = () => {
  const { verifiedUser } = useOutletContext<{ verifiedUser: string | null }>();
  const [isEditing, setIsEditing] = useState(false);

  const handleSave = async (bio: string, avatar: File | null) => {
    // Send PATCH/PUT to your API here
    console.log("Saving...", bio, avatar);
    setIsEditing(false);
  };

  if (!verifiedUser) {
    return <p className="text-center text-red-600">User not logged in</p>;
  }

  return isEditing ? (
    <ProfileEditForm
      initialBio="" 
      onSave={handleSave}
      onCancel={() => setIsEditing(false)}
    />
  ) : (
    <ProfileView
      user={verifiedUser}
      email=""
      bio=""
      joined=""
      onEdit={() => setIsEditing(true)}
    />
  );
};

export default Profile;




===== ./microservices/frontend/src/pages/Register.tsx =====
// microservices/frontend/src/pages/Register.tsx

import React, { useState, useRef } from "react";
import { useNavigate } from "react-router-dom";

interface FormData {
  firstname: string;
  lastname: string;
  email: string;
  username: string;
  password: string;
}

const Register: React.FC = () => {
  const [form, setForm] = useState<FormData>({
    firstname: "",
    lastname: "",
    email: "",
    username: "",
    password: "",
  });

  const [message, setMessage] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [checking, setChecking] = useState<{ email?: boolean; username?: boolean }>({});
  const [availability, setAvailability] = useState<{ email?: boolean; username?: boolean }>({});
  const navigate = useNavigate();
  const typingTimeout = useRef<number | null>(null);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
    setMessage("");

    if ((name === "email" || name === "username") && value.trim() === "") {
      setAvailability((prev) => ({ ...prev, [name]: undefined }));
      setChecking((prev) => ({ ...prev, [name]: false }));
      return;
    }

    if (name === "email" || name === "username") {
      setChecking((prev) => ({ ...prev, [name]: true }));

      if (typingTimeout.current) {
        clearTimeout(typingTimeout.current);
      }

      typingTimeout.current = setTimeout(async () => {
        try {
          const res = await fetch(`${import.meta.env.VITE_API_URL}/check?${name}=${value}`);
          const data = await res.json();
          setAvailability((prev) => ({ ...prev, [name]: data.available }));
        } catch {
          setAvailability((prev) => ({ ...prev, [name]: false }));
        } finally {
          setChecking((prev) => ({ ...prev, [name]: false }));
        }
      }, 500);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");

    if (availability.email === false || availability.username === false) {
      setMessage("Email or username already exists");
      return;
    }

    setSubmitting(true);

    try {
      const res = await fetch(`${import.meta.env.VITE_API_URL}/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });

      const data = await res.json();

      if (res.ok) {
        navigate("/", {
          state: { flash: "🎉 Account created. Please log in." },
        });
      } else {
        setMessage(data.detail || "Failed to register");
      }
    } catch {
      setMessage("An error occurred during registration");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-6">
      <form
        onSubmit={handleSubmit}
        className="bg-white p-8 rounded shadow-md w-full max-w-md"
      >
        <h2 className="text-2xl font-bold mb-6 text-center text-blue-700">
          Create an Account
        </h2>

        {["firstname", "lastname", "email", "username", "password"].map((field) => (
          <div key={field} className="mb-4">
            <label htmlFor={field} className="block text-sm font-medium mb-1 capitalize">
              {field}
            </label>
            <div className="relative">
              <input
                type={field === "password" ? "password" : "text"}
                name={field}
                id={field}
                value={(form as any)[field]}
                onChange={handleChange}
                required
                className="w-full p-2 pr-10 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
              />

              {(field === "email" || field === "username") && (
                <div className="absolute right-2 top-2 text-sm">
                  {checking[field] ? (
                    <span className="text-gray-400 animate-pulse">⌛</span>
                  ) : availability[field] === true ? (
                    <span className="text-green-500">✅</span>
                  ) : availability[field] === false ? (
                    <span className="text-red-500">❌</span>
                  ) : null}
                </div>
              )}
            </div>

            {(field === "email" || field === "username") &&
              availability[field] === false &&
              !checking[field] && (
                <p className="text-sm text-red-500 mt-1">
                  {field.charAt(0).toUpperCase() + field.slice(1)} already in use
                </p>
              )}
          </div>
        ))}

        <button
          type="submit"
          disabled={
            submitting ||
            checking.email ||
            checking.username ||
            availability.email === false ||
            availability.username === false
          }
          className="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded font-semibold disabled:opacity-50"
        >
          {submitting ? "Registering..." : "Register"}
        </button>

        {message && (
          <p className="mt-4 text-center text-sm text-gray-700">{message}</p>
        )}
      </form>
    </div>
  );
};

export default Register;




===== ./microservices/frontend/tailwind.config.js =====
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}




===== ./microservices/frontend/tsconfig.json =====
{
  "compilerOptions": {
    "target": "ESNext",
    "useDefineForClassFields": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "strict": true,
    "jsx": "react-jsx",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "skipLibCheck": true,
    "types": ["vite/client"]
  },
  "include": ["src", "vite-env.d.ts"]
}



===== ./microservices/frontend/vite-env.d.ts =====
// kubeship/microservices/frontend/vite-env.d.ts
/// <reference types="vite/client" />




===== ./microservices/frontend/vite.config.ts =====
// kubeship/microservices/frontend/vite.config.ts
/// <reference types="node" />

import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';


export default defineConfig(({ mode }) => {
  process.env = { ...process.env, ...loadEnv(mode, process.cwd()) };
  return {
    plugins: [react()],
    server: {
      port: 3000,
    },
  };
});




===== ./nginx/Dockerfile =====
# kubeship/nginx/Dockerfile

# nginx Dockerfile
FROM nginx:1.25-alpine

# Copy custom config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80




===== ./nginx/nginx.conf =====
# kubeship/nginx/nginx.conf
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/json;

    sendfile        on;
    keepalive_timeout  65;

    # Upstream backend service for auth
    upstream auth_service {
        server auth-service:8001;
    }

    server {
        listen 80;

        # Health check endpoint
        location /health {
            return 200 '{"status":"healthy"}';
            add_header Content-Type application/json;
        }

        # Auth service routing (with versioning)
        # Will forward /v1/auth/* directly to auth-service
        location /v1/auth/ {
            proxy_pass http://auth_service/v1/auth/;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            proxy_connect_timeout 5s;
            proxy_send_timeout 10s;
            proxy_read_timeout 10s;
            client_max_body_size 1M;
        }

        location / {
            return 404 '{"error":"Not Found"}';
            add_header Content-Type application/json;
        }
    }
}




===== ./README.md =====

# Project: KubeShip – GitOps Platform with ArgoCD and EKS

## What Is KubeShip?

**KubeShip** is a real-world GitOps platform that automates the deployment and management of containerized applications using:

- **Amazon EKS** for Kubernetes orchestration
- **ArgoCD** for GitOps-based continuous delivery
- **Terraform** for infrastructure as code
- **Helm** for Kubernetes packaging
- **GitHub Actions** for CI pipelines
- **React + FastAPI** for microservices
- **PostgreSQL + Redis** for backend storage

This project shows how modern teams deploy applications at scale with automation and best DevOps practices.

---

## Why KubeShip?

Because deploying microservices manually doesn’t scale. You need:

- Declarative infrastructure (Terraform)
- Automated provisioning (EKS)
- GitOps deployment model (ArgoCD)
- CI/CD pipelines (GitHub Actions)
- Monitoring and scalability

KubeShip combines all of these in one integrated stack.

---

## Architecture Overview

### Core Components

| Layer             | Tool                         |
|-------------------|------------------------------|
| Infra Provision   | Terraform                    |
| Cluster           | Amazon EKS                   |
| GitOps CD         | ArgoCD                       |
| Helm Packaging    | Helm                         |
| CI/CD             | GitHub Actions               |
| Container Registry| Amazon ECR                   |
| Microservices     | FastAPI, React, PostgreSQL   |
| Monitoring        | Prometheus + Grafana         |

---

## Architecture Diagram

```
                        ┌──────────────────────────────┐
                        │     GitHub Repo (IaC + App)  │
                        └────────────┬─────────────────┘
                                     │ Push
                          ┌──────────▼──────────┐
                          │    GitHub Actions   │────────────┐
                          └──────────┬──────────┘            │
                                     │ Image Build/Push      │
                          ┌──────────▼──────────┐            │
                          │    Amazon ECR       │            │
                          └─────────────────────┘            │
                                                             ▼
                                               ┌────────────────────────┐
                                               │   Amazon EKS Cluster   │
                                               │   (Provisioned via TF) │
                                               └──────────┬─────────────┘
                                                          │
                                                ┌─────────▼─────────┐
                                                │     ArgoCD        │
                                                │  (GitOps CD Tool) │
                                                └──────┬────────────┘
                                                       │
                                           ┌───────────▼────────────┐
                                           │   Helm Deployments      │
                                           │  (Frontend, API, Redis) │
                                           └─────────────────────────┘
```

---

## Project Structure

```
kubeship/
├── terraform/              # VPC + EKS via Terraform
├── microservices/          # React + FastAPI + DB
│   ├── api-gateway/
│   ├── auth-service/
│   └── frontend/
├── helm-charts/            # Helm charts per service
├── manifests/              # ArgoCD apps and projects
└── .github/workflows/      # CI build and push pipelines
```

---

## Infrastructure Provisioning with Terraform

Provision:

- VPC with public and private subnets
- NAT Gateway for outbound traffic
- Amazon EKS cluster
- IAM roles and node groups

Modules used:
- `terraform-aws-modules/vpc/aws`
- `terraform-aws-modules/eks/aws`

Command:

```bash
terraform init
terraform apply
```

---

## GitOps with ArgoCD

ArgoCD tracks:
- Git repo for Helm chart changes
- Helm charts from `helm-charts/`
- Syncs them to EKS cluster

To access ArgoCD:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open: [https://localhost:8080](https://localhost:8080)

---

## CI/CD with GitHub Actions

- Builds Docker images
- Pushes to ECR
- ArgoCD picks up and syncs latest deployment

CI defined in: `.github/workflows/deploy.yaml`

---

## Testing and Observability

Post-deployment:

- Validate apps in ArgoCD UI
- `kubectl get pods -A` for health checks
- Test endpoints using ALB DNS

Monitoring with Prometheus + Grafana (optional):

```bash
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

---

## ✅ Real-World Problem Solving

| Concern                    | KubeShip Solution               |
|----------------------------|----------------------------------|
| Scalable Deployments       | GitOps + ArgoCD                 |
| CI/CD                      | GitHub Actions + ECR            |
| Infra as Code              | Terraform                       |
| Secrets + Networking       | EKS best practices              |
| Observability              | Prometheus + Grafana            |

---

## What’s Next?

- [ ] Add custom domain with cert-manager + Route 53
- [ ] Use Sealed Secrets or External Secrets
- [ ] Setup staging and prod ArgoCD environments
- [ ] Enable autoscaling (HPA)

---

## Summary

KubeShip lets you:

✅ Learn GitOps & EKS  
✅ Use Terraform professionally  
✅ Automate deployments  
✅ Build full-stack apps in Kubernetes

---

## Author

Built with ❤️ by Celestine — [GitHub](https://github.com/celestn1)




