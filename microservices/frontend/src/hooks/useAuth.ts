// kubeship/microservices/frontend/src/hooks/useAuth.ts

import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { verifyToken } from "../utils/apiClient";

interface UserPayload {
  email: string;
  firstname: string;
  exp?: number; // JWT expiration time (in seconds)
}

export const useAuth = () => {
  const [user, setUser] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  const loginWithToken = (token: string) => {
    localStorage.setItem("token", token);
    const payload = parseJwt(token);

    if (payload && isTokenFresh(payload)) {
      setUser(payload.firstname);
    } else {
      logout();
    }
  };

  const logout = () => {
    localStorage.removeItem("token");
    setUser(null);
    navigate("/login");
  };

  const isTokenFresh = (payload: UserPayload | null): boolean => {
    if (!payload?.exp) return false;
    const now = Math.floor(Date.now() / 1000); // seconds since epoch
    return payload.exp > now;
  };

  useEffect(() => {
    const checkToken = async () => {
      const token = localStorage.getItem("token");
      if (!token) {
        setLoading(false);
        return;
      }

      const payload = parseJwt(token);
      const fresh = isTokenFresh(payload);

      try {
        const result = await verifyToken(token);
        if (result.valid && result.firstname && fresh) {
          setUser(result.firstname);
        } else {
          logout();
        }
      } catch {
        logout();
      } finally {
        setLoading(false);
      }
    };

    checkToken();
  }, []);

  return { user, loginWithToken, logout, loading };
};

const parseJwt = (token: string): UserPayload | null => {
  try {
    const base64 = token.split(".")[1].replace(/-/g, "+").replace(/_/g, "/");
    const json = decodeURIComponent(
      atob(base64)
        .split("")
        .map((c) => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2))
        .join("")
    );
    return JSON.parse(json);
  } catch {
    return null;
  }
};
