import React, { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import toast from "react-hot-toast";
import { login } from "../utils/apiClient";
import { useAuth } from "../hooks/useAuth";
import { useFormInput } from "../hooks/useFormInput";
import InputField from "../components/Form/InputField";
import PasswordField from "../components/Form/PasswordField";
import Button from "../components/UI/Button";
import { isValidUsername, isValidEmail } from "../../../../shared/validators";
import { UserIcon } from "lucide-react";

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
    <div className="min-h-screen bg-[#0a2a6c] bg-[url('/pattern.svg')] bg-cover bg-no-repeat flex items-center justify-center p-4">
      <div className="bg-white p-8 rounded-lg shadow-md max-w-sm w-full">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="flex flex-col items-center mb-4">
            <div className="bg-blue-600 text-white rounded-full w-10 h-10 flex items-center justify-center font-bold">
              M
            </div>
            <h2 className="text-lg font-semibold mt-2">Login to KubeShip</h2>
          </div>

          <InputField
            label="Email or Username"
            name="username"
            type="text"
            value={values.username}
            onChange={handleChange}
            autoComplete="username"
            required
            icon={<UserIcon className="w-5 h-5 text-gray-400" />}
          />

          <PasswordField
            label="Password"
            name="password"
            value={values.password}
            onChange={handleChange}
            autoComplete="current-password"
            required
          />

          <Button
            type="submit"
            label={loading ? "Logging in..." : "Next"}
            disabled={loading}
            full
          />

          {message && <p className="text-center text-sm text-red-600">{message}</p>}

          <div className="mt-4 text-center text-sm">
            <a href="/forgot-password" className="text-blue-600 hover:underline">
              Forgot Password?
            </a>
          </div>
        </form>

        <div className="mt-6 text-center text-sm text-gray-600">
          New to KubeShip?{' '}
          <a href="/register" className="text-blue-700 underline">
            Sign Up
          </a>
        </div>
      </div>

      <p className="absolute bottom-4 text-xs text-white text-center w-full">
        Licensed and deployed on secure cloud infrastructure.
      </p>
    </div>
  );
};

export default Login;
