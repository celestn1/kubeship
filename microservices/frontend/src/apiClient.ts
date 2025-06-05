// kubeship/microservices/frontend/src/apiClient.ts

import { getErrorMessage, extractStatusCode } from "./errorHandler";

export async function register(username: string, password: string) {
  try {
    const res = await fetch(`${import.meta.env.VITE_API_URL}/auth/register`, {
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
    const statusCode = extractStatusCode(err);
    return {
      message: getErrorMessage(statusCode ?? 0) || "Network error during registration",
      success: false,
    };
  }
}

export const login = async (username: string, password: string) => {
  try {
    const response = await fetch(`${import.meta.env.VITE_API_URL}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });

    const data = await response.json();

    return response.ok
      ? { token: data.access_token, message: "Login successful" }
      : { token: null, message: data.detail || "Login failed" };
  } catch (err) {
    const statusCode = extractStatusCode(err);
    return {
      token: null,
      message: getErrorMessage(statusCode ?? 0) || "Network error during login",
    };
  }
};
