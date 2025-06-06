// kubeship/microservices/frontend/src/pages/Login.tsx

import React, { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import toast from "react-hot-toast";
import { login } from "../utils/apiClient";
import { useAuth } from "../hooks/useAuth";
import { useFormInput } from "../hooks/useFormInput";
import InputField from "../components/Form/InputField";
import PasswordField from "../components/Form/PasswordField";
import Card from "../components/UI/Card";
import Button from "../components/UI/Button";
import { isValidUsername, isValidEmail } from "../../../../shared/validators";

const Login: React.FC = () => {
  const { values, handleChange, getTrimmed } = useFormInput({
    username: "",
    password: "",
  });

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
  }, [location.key]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");
    setLoading(true);

    const { username, password } = getTrimmed();

    const isValidInput = isValidUsername(username) || isValidEmail(username);
    if (!isValidInput) {
      setMessage("Enter a valid email or username.");
      setLoading(false);
      return;
    }

    try {
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
      <Card>
        <form onSubmit={handleSubmit} className="space-y-4">
          <h2 className="text-2xl font-bold text-center text-blue-700">
            🚢 KubeShip Frontend
          </h2>

          <InputField
            label="Email or Username"
            name="username"
            type="text"
            value={values.username}
            onChange={handleChange}
            autoComplete="username"
            required
          />

          <PasswordField
            label="Password"
            name="password"
            value={values.password}
            onChange={handleChange}
            autoComplete="current-password"
            required
          />

          <Button type="submit" label={loading ? "Logging in..." : "Login"} disabled={loading} full />

          {message && <p className="text-center text-sm text-red-600">{message}</p>}

          <div className="mt-4 text-center text-sm space-y-2">
            <p>
              Don’t have an account?{" "}
              <a href="/register" className="text-blue-700 underline">
                Sign up
              </a>
            </p>
            <p>
              Forgot your password?{" "}
              <a href="/forgot-password" className="text-blue-600 underline">
                Reset it
              </a>
            </p>
          </div>
        </form>
      </Card>
    </div>
  );
};

export default Login;
