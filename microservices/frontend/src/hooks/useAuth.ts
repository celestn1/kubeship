// kubeship/microservices/frontend/src/hooks/useAuth.ts

import { useEffect, useState } from "react";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

export function useAuth() {
  const [token, setToken] = useState<string | null>(localStorage.getItem("token"));
  const [user, setUser] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const verifyToken = async () => {
    if (!token) {
      setUser(null);
      setLoading(false);
      return;
    }

    try {
      const res = await fetch(`${API_URL}/verify?token=${token}`);
      const data = await res.json();

      if (data.valid) {
        setUser(data.firstname);
      } else {
        setToken(null);
        localStorage.removeItem("token");
      }
    } catch {
      setToken(null);
      localStorage.removeItem("token");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    verifyToken();
  }, [token]);

  const loginWithToken = (newToken: string) => {
    localStorage.setItem("token", newToken);
    setToken(newToken);
  };

  const logout = () => {
    localStorage.removeItem("token");
    setToken(null);
    setUser(null);
  };

  return { token, user, loading, loginWithToken, logout };
}
