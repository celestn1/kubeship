// kubeship/microservices/frontend/src/pages/ResetPassword.tsx

import React, { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import PasswordField from "../components/Form/PasswordField";
import Button from "../components/UI/Button";
import Card from "../components/UI/Card";
import { isStrongPassword } from "../../../../shared/validators";
import toast from "react-hot-toast";

const ResetPassword: React.FC = () => {
  const { token } = useParams();
  const navigate = useNavigate();

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState("");
  const [showSuccessModal, setShowSuccessModal] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");

    const trimmedPassword = password.trim();
    const trimmedConfirm = confirmPassword.trim();

    if (!isStrongPassword(trimmedPassword)) {
      setMessage("Password must be at least 8 characters and include letters and numbers.");
      return;
    }

    if (trimmedPassword !== trimmedConfirm) {
      setMessage("Passwords do not match.");
      return;
    }

    setSubmitting(true);

    try {
      const res = await fetch(`${import.meta.env.VITE_API_URL}/reset-password`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ token, password: trimmedPassword }),
      });

      if (res.status === 429) {
        setMessage("You're doing that too much. Try again in 15 minutes.");
        return;
      }

      if (res.ok) {
        setShowSuccessModal(true);
        setTimeout(() => {
          navigate("/login", {
            state: { flash: "🎉 Password reset successful. Please log in." },
          });
        }, 3000);
        return;
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

          <PasswordField
            label="New Password"
            name="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="new-password"
            required
            helperText="Minimum 8 characters including letters and numbers"
          />

          <PasswordField
            label="Confirm Password"
            name="confirmPassword"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            autoComplete="new-password"
            required
            helperText="Re-enter your new password"
          />

          <Button
            type="submit"
            label={submitting ? "Resetting..." : "Reset Password"}
            disabled={
              submitting ||
              !isStrongPassword(password) ||
              password !== confirmPassword
            }
            full
          />

          {message && (
            <p className="text-center text-sm text-red-600">{message}</p>
          )}
        </form>
      </Card>

      {showSuccessModal && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div className="bg-white p-6 rounded-lg shadow-lg text-center space-y-2">
            <h3 className="text-green-600 font-semibold text-xl">
              Password reset successful!
            </h3>
            <p className="text-sm text-gray-700">Redirecting to login...</p>
          </div>
        </div>
      )}
    </div>
  );
};

export default ResetPassword;
