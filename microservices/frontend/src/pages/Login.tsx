// kubeship/microservices/frontend/src/pages/Login.tsx

import React, { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import toast from "react-hot-toast";
import { login } from "../utils/apiClient";
import { useAuth } from "../hooks/useAuth";
import { useFormInput } from "../hooks/useFormInput";
import InputField from "../components/Form/InputField";
import PasswordField from "../components/Form/PasswordField";
import Button from "../components/UI/Button";
import Card from "../components/UI/Card";
import { isValidUsername, isValidEmail } from "../../../../shared/validators";
import { MailIcon, UserIcon } from "lucide-react";

const Login: React.FC = () => {
  const { values, handleChange, getTrimmed } = useFormInput({
    identifier: "",
    password: "",
  });

  const [step, setStep] = useState<1 | 2>(1);
  const [tab, setTab] = useState<"email" | "username">("email");
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

  const handleIdentifierSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const { identifier } = getTrimmed();

    const isValidInput = tab === "email" ? isValidEmail(identifier) : isValidUsername(identifier);
    if (!isValidInput) {
      setMessage(`Enter a valid ${tab}.`);
      return;
    }
    setStep(2);
    setMessage("");
  };

  const handlePasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");
    setLoading(true);

    const { identifier, password } = getTrimmed();

    try {
      const result = await login(identifier, password);
      setLoading(false);

      if (result.token) {
        toast.success("Login successful");
        loginWithToken(result.token);
        navigate("/dashboard");
      } else {
        setMessage(result.message || "Login failed. Try again.");
      }
    } catch {
      setLoading(false);
      setMessage("Network error. Please try again.");
    }
  };

  return (
    <div className="min-h-screen bg-[#0a2a6c] bg-[url('/pattern.svg')] bg-cover bg-no-repeat flex flex-col items-center justify-center p-4">
      <Card className="w-full max-w-sm p-8">
        <div className="flex flex-col items-center justify-center text-center mb-4">
          <img
            src="/assets/kubeship-icon.png"
            alt="KubeShip Icon"
            className="w-10 h-10 mx-auto"
          />

          <h2 className="text-lg font-semibold mt-2 w-full">Login to KubeShip</h2>
        </div>

        {step === 1 ? (
          <form onSubmit={handleIdentifierSubmit} className="space-y-4">
            <div className="flex justify-center space-x-6 text-sm border-b mb-4">
              {["email", "username"].map((t) => (
                <button
                  type="button"
                  key={t}
                  onClick={() => setTab(t as "email" | "username")}
                  className={`pb-2 ${tab === t ? "text-blue-600 border-b-2 border-blue-600 font-medium" : "text-gray-500"}`}
                >
                  {t === "email" ? "Email" : "Username"}
                </button>
              ))}
            </div>

            <InputField
              label=""
              name="identifier"
              placeholder={tab === "email" ? "Enter your email" : "Enter your username"}
              type="text"
              value={values.identifier}
              onChange={handleChange}
              autoComplete={tab === "email" ? "email" : "username"}
              required
              icon={tab === "email" ? <MailIcon className="w-5 h-5 text-gray-400" /> : <UserIcon className="w-5 h-5 text-gray-400" />}
            />

            <Button
              type="submit"
              label="Next"
              disabled={!values.identifier}
              full
            />

            {message && <p className="text-center text-sm text-red-600">{message}</p>}
          </form>
        ) : (
          <form onSubmit={handlePasswordSubmit} className="space-y-4">
            <PasswordField
              name="password"
              value={values.password}
              onChange={handleChange}
              autoComplete="current-password"
              required
            />

            <div className="text-right text-sm">
              <a href="/forgot-password" className="text-blue-600 hover:underline">
                Forgot Password?
              </a>
            </div>

            <Button
              type="submit"
              label={loading ? "Logging in..." : "Login"}
              disabled={loading}
              full
            />

            <button
              type="button"
              onClick={() => setStep(1)}
              className="block w-full text-sm text-center text-blue-600 hover:underline"
            >
              Back
            </button>

            {message && <p className="text-center text-sm text-red-600">{message}</p>}
          </form>
        )}
      </Card>

      {/* Pill-style signup footer */}
      <div className="mt-6 bg-white/10 px-6 py-3 rounded-full text-white text-sm text-center">
        New to KubeShip?{" "}
        <a href="/register" className="font-bold underline">
          Sign Up
        </a>
      </div>
    </div>
  );
};

export default Login;
