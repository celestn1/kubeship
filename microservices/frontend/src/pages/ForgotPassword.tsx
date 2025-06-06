// kubeship/microservices/frontend/src/pages/ForgotPassword.tsx

import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import InputField from "../components/Form/InputField";
import Button from "../components/UI/Button";
import Card from "../components/UI/Card";
import { isValidEmail } from "../../../../shared/validators";
import toast from "react-hot-toast";

const ForgotPassword: React.FC = () => {
  const [email, setEmail] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState("");
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");

    const trimmedEmail = email.trim();

    if (!isValidEmail(trimmedEmail)) {
      setMessage("Please enter a valid email address.");
      return;
    }

    setSubmitting(true);

    try {
      const res = await fetch(`${import.meta.env.VITE_API_URL}/request-password-reset`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: trimmedEmail }),
      });

      if (res.ok) {
        toast.success("If your email is registered, reset instructions have been sent.");
        navigate("/login");
      } else {
        const data = await res.json();
        setMessage(data.detail || "Could not process your request.");
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
          {/* ✅ KubeShip Header */}
          <h2 className="text-2xl font-bold text-center text-blue-700 mb-2">
            <Link to="/" className="hover:underline">🚢 KubeShip Frontend</Link>
          </h2>

          <p className="text-center text-gray-600 text-sm mb-4">
            Forgot Password? Enter your email to receive a reset link
          </p>

          <InputField
            label=""
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

          <Button
            type="submit"
            label={submitting ? "Submitting..." : "Send Reset Link"}
            disabled={submitting || !isValidEmail(email)}
            full
          />

          {message && (
            <p className="text-center text-sm text-red-600">{message}</p>
          )}

          {/* ✅ CTA Footer */}
          <p className="text-center text-sm mt-4">
            Remember your password?{" "}
            <Link to="/login" className="text-blue-600 underline">
              Sign in
            </Link>
          </p>
        </form>
      </Card>
    </div>
  );
};

export default ForgotPassword;
