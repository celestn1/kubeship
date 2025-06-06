// kubeship/microservices/frontend/src/pages/ResetPassword.tsx

import React, { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import InputField from "../components/Form/InputField";
import PasswordField from "../components/Form/PasswordField";
import Button from "../components/UI/Button";
import Card from "../components/UI/Card";
import { isValidEmail, isStrongPassword } from "../../../../shared/validators";
import toast from "react-hot-toast";

const ResetPassword: React.FC = () => {
  const { token } = useParams();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");

    const trimmedEmail = email.trim();
    const trimmedPassword = password.trim();

    if (!isValidEmail(trimmedEmail)) {
      setMessage("Please enter a valid email.");
      return;
    }

    if (!isStrongPassword(trimmedPassword)) {
      setMessage("Password must be at least 8 characters and include letters and numbers.");
      return;
    }

    setSubmitting(true);

    try {
      const res = await fetch(`${import.meta.env.VITE_API_URL}/reset-password`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ token, password: trimmedPassword }),
      });

      if (res.ok) {
        toast.success("✅ Password reset successful!");
        navigate("/login", { state: { flash: "🎉 Password reset successful. Please log in." } });
      } else {
        const data = await res.json();
        setMessage(data.detail || "Failed to reset password.");
      }
    } catch {
      setMessage("Network error. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-6">
      <Card>
        <form onSubmit={handleSubmit} className="space-y-4">
          <h2 className="text-2xl font-bold text-center text-blue-700 mb-4">
            Reset Password
          </h2>

          <InputField
            label="Email"
            name="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            autoComplete="email"
            required
            showStatusIcon
            status={
              email.length === 0
                ? undefined
                : isValidEmail(email)
                ? "valid"
                : "invalid"
            }
          />

          <PasswordField
            label="New Password"
            name="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="new-password"
            required
            helperText="Minimum 8 characters including letters and numbers"
          />

          <Button
            type="submit"
            label={submitting ? "Resetting..." : "Reset Password"}
            disabled={submitting || !isValidEmail(email) || !isStrongPassword(password)}
            full
          />

          {message && (
            <p className="text-center text-sm text-red-600">{message}</p>
          )}
        </form>
      </Card>
    </div>
  );
};

export default ResetPassword;
