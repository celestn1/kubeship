// kubeship/microservices/frontend/src/utils/apiClient.ts

const API_URL = import.meta.env.VITE_API_URL;

const defaultHeaders = {
  "Content-Type": "application/json"
};

async function handleResponse(res: Response) {
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.detail || "Unexpected error");
  return data;
}

export async function login(username: string, password: string) {
  const res = await fetch(`${API_URL}/login`, {
    method: "POST",
    headers: defaultHeaders,
    body: JSON.stringify({ username, password })
  });

  try {
    const data = await handleResponse(res);
    return { token: data.access_token };
  } catch (err: any) {
    return { token: null, message: err.message };
  }
}

export async function registerUser(payload: Record<string, string>) {
  const res = await fetch(`${API_URL}/register`, {
    method: "POST",
    headers: defaultHeaders,
    body: JSON.stringify(payload)
  });

  return handleResponse(res);
}

export async function checkAvailability(type: "email" | "username", value: string) {
  const res = await fetch(`${API_URL}/check?${type}=${value}`);
  return handleResponse(res);
}

export async function requestPasswordReset(email: string) {
  const res = await fetch(`${API_URL}/request-password-reset`, {
    method: "POST",
    headers: defaultHeaders,
    body: JSON.stringify({ email })
  });

  return handleResponse(res);
}

export async function resetPassword(token: string, password: string) {
  const res = await fetch(`${API_URL}/reset-password`, {
    method: "POST",
    headers: defaultHeaders,
    body: JSON.stringify({ token, password })
  });

  return handleResponse(res);
}

export async function verifyToken(token: string) {
  const res = await fetch(`${API_URL}/verify-token`, {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });

  if (!res.ok) {
    throw new Error("Token invalid or expired");
  }

  return await res.json(); // This includes `valid`, `email`, and `firstname`
}
