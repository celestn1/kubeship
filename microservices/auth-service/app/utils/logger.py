# kubeship/microservices/auth-service/app/utils/logger.py

# Set up logging configuration as needed for debugging
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s"
)

logger = logging.getLogger("kubeship-auth")
