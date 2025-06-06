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
      : { token: null, message: data?.detail || "Login failed" };
  } catch {
    return {
      token: null,
      message: "Network error. Please check your connection.",
    };
  }
};

