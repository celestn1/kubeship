// kubeship/microservices/frontend/src/api.ts

const API_URL = import.meta.env.VITE_API_URL;

export const register = async (username: string, password: string) => {
  const response = await fetch(`${API_URL}/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password }),
  });
  return response.json();
};
