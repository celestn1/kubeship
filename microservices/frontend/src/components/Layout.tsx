// kubeship/microservices/frontend/src/components/Layout.tsx

import React, { useEffect, useState } from "react";
import { Outlet, Link, useNavigate } from "react-router-dom";
import { register, login } from "../apiClient";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

// ✅ Export context type for downstream use
export type LayoutContextType = {
  verifiedUser: string | null;
  handleLogout: () => void;
};

const Layout = () => {
  const [username, setUsername] = useState("frontenduser");
  const [password, setPassword] = useState("frontendpass");
  const [message, setMessage] = useState("");
  const [token, setToken] = useState<string | null>(localStorage.getItem("token"));
  const [verifiedUser, setVerifiedUser] = useState<string | null>(null);
  const navigate = useNavigate();

  const handleRegister = async () => {
    const result = await register(username, password);
    setMessage(result.message);
  };

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
    setMessage("Logged Out Successfully");
    navigate("/");
  };

  useEffect(() => {
    const verifyToken = async () => {
      if (!token) return;
      try {
        const res = await fetch(`${API_URL}/auth/verify?token=${token}`);
        const json = await res.json();
        if (json.valid) {
          setVerifiedUser(json.user);
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

  return (
    <div className="min-h-screen bg-gray-100 p-4">
      <h1 className="text-3xl font-bold text-center text-blue-600 mb-6">
        🚢 KubeShip Frontend
      </h1>

      <nav className="flex justify-center space-x-4 mb-6">
        {token && (
          <>
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
          </>
        )}
      </nav>

      {!token ? (
        <div className="bg-white shadow-md rounded p-6 w-full max-w-md mx-auto">
          <input
            type="text"
            placeholder="Username"
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
          <div className="flex justify-between">
            <button
              onClick={handleRegister}
              className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded"
            >
              Register
            </button>
            <button
              onClick={handleLogin}
              className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded"
            >
              Login
            </button>
          </div>
          <p className="mt-4 text-sm text-gray-700">{message}</p>
        </div>
      ) : (
        // ✅ Pass context to children
        <Outlet context={{ verifiedUser, handleLogout }} />
      )}
    </div>
  );
};

export default Layout;