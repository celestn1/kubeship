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
