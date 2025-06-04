// kubeship/microservices/frontend/src/App.tsx

import React, { useState, useEffect } from "react";
import { register, login } from "./apiClient";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

function App() {
  const [username, setUsername] = useState("frontenduser");
  const [password, setPassword] = useState("frontendpass");
  const [message, setMessage] = useState("");
  const [token, setToken] = useState<string | null>("");

  const handleRegister = async () => {
    const result = await register(username, password);
    setMessage(result.message);
  };

  const handleLogin = async () => {
    try {
      const result = await login(username, password);
      if (result.token) {
        setMessage("Login successful");
        localStorage.setItem("token", result.token);
        setToken(result.token);
      } else {
        setMessage(result.message || "Login failed");
      }
    } catch (err) {
      setMessage("Login error");
    }
  };

  const handleLogout = () => {
    localStorage.removeItem("token");
    setToken(null);
    setMessage("Logged out successfully");
  };

  useEffect(() => {
    const verifyToken = async () => {
      if (!token) return;
      try {
        const res = await fetch(`${API_URL}/auth/verify?token=${token}`);
        const json = await res.json();
        console.log("Token verification result:", json);
      } catch (err) {
        console.error("Token verification failed:", err);
      }
    };
    verifyToken();
  }, [token]);

  return (
    <div style={{ textAlign: "center", marginTop: "4rem" }}>
      <h1>🚢 KubeShip Frontend: This is the Vite + TypeScript + React UI</h1>

      <input
        type="text"
        placeholder="Username"
        value={username}
        onChange={(e) => setUsername(e.target.value)}
      /><br />

      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      /><br />

      <button onClick={handleRegister}>Register</button>
      <button onClick={handleLogin}>Login</button>
      {token && <button onClick={handleLogout}>Logout</button>}

      <p>{message}</p>

      {token && (
        <div>
          <h4>JWT Token</h4>
          <code style={{ wordBreak: "break-all" }}>{token}</code>
        </div>
      )}
    </div>
  );
}

export default App;
