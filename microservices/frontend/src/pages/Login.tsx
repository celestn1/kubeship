// kubeship/microservices/frontend/src/pages/Login.tsx

import React, { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import toast from "react-hot-toast";
import { login } from "../apiClient";
import { useAuth } from "../hooks/useAuth";
import { useFormInput } from "../hooks/useFormInput";

const Login: React.FC = () => {
  const { values, handleChange, getTrimmed } = useFormInput({
    username: "",
    password: "",
  });

  const [showPassword, setShowPassword] = useState(false);
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();
  const location = useLocation();
  const { loginWithToken } = useAuth();

  useEffect(() => {
    const flash = location.state?.flash;

    if (flash) {
      toast.dismiss();
      toast.success(flash); 
      navigate(location.pathname, { replace: true, state: {} });
    }
  }, [location.key]); // more reliable than full location


  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");
    setLoading(true);

    try {
      const { username, password } = getTrimmed();
      const result = await login(username, password);
      setLoading(false);

      if (result.token) {
        toast.success("Login successful");
        loginWithToken(result.token);
        navigate("/dashboard");
      } else {
        switch (result.message) {
          case "Email or username not found":
            setMessage("No account found for that email or username.");
            break;
          case "Incorrect password":
            setMessage("The password you entered is incorrect.");
            break;
          default:
            setMessage(result.message || "Login failed. Please try again.");
        }
      }
    } catch {
      setLoading(false);
      setMessage("Network error. Please check your connection.");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-6">
      <form
        onSubmit={handleSubmit}
        className="bg-white p-8 rounded shadow-md w-full max-w-md"
      >
        <h2 className="text-2xl font-bold text-center text-blue-700 mb-6">
          🚢 KubeShip Frontend
        </h2>

        <input
          type="text"
          name="username"
          placeholder="Email or username"
          value={values.username}
          onChange={handleChange}
          required
          className="w-full p-2 mb-4 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
        />

        <div className="relative mb-4">
          <input
            type={showPassword ? "text" : "password"}
            name="password"
            placeholder="Password"
            value={values.password}
            onChange={handleChange}
            required
            className="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="absolute inset-y-0 right-2 flex items-center text-sm text-blue-600 hover:underline"
          >
            {showPassword ? "Hide" : "Show"}
          </button>
        </div>

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded font-semibold disabled:opacity-50"
        >
          {loading ? "Logging in..." : "Login"}
        </button>

        <p className="mt-4 text-center text-sm">
          Don’t have an account?{" "}
          <a href="/register" className="text-blue-700 underline">
            Sign up
          </a>
        </p>

        {message && (
          <p className="mt-4 text-center text-sm text-red-600">{message}</p>
        )}
      </form>
    </div>
  );
};

export default Login;
