// kubeship/microservices/frontend/src/pages/Register.tsx

import React, { useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useFormInput } from "../hooks/useFormInput";
import InputField from "../components/Form/InputField";
import PasswordField from "../components/Form/PasswordField";
import Button from "../components/UI/Button";
import Card from "../components/UI/Card";
import {
  isValidEmail,
  isValidUsername,
  isStrongPassword,
} from "../../../../shared/validators";

const Register: React.FC = () => {
  const { values: form, handleChange, getTrimmed } = useFormInput({
    firstname: "",
    lastname: "",
    email: "",
    username: "",
    password: "",
  });

  const [message, setMessage] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [checking, setChecking] = useState<{ email?: boolean; username?: boolean }>({});
  const [availability, setAvailability] = useState<{ email?: boolean; username?: boolean }>({});
  const navigate = useNavigate();
  const typingTimeout = useRef<number | null>(null);

  const checkAvailability = (name: string, value: string) => {
    const trimmed = value.trim();
    if ((name === "email" && !isValidEmail(trimmed)) || trimmed === "") {
      setAvailability((prev) => ({ ...prev, [name]: false }));
      return;
    }

    setChecking((prev) => ({ ...prev, [name]: true }));
    if (typingTimeout.current) clearTimeout(typingTimeout.current);

    typingTimeout.current = window.setTimeout(async () => {
      try {
        const res = await fetch(`${import.meta.env.VITE_API_URL}/check?${name}=${trimmed}`);
        const data = await res.json();
        setAvailability((prev) => ({ ...prev, [name]: data.available }));
      } catch {
        setAvailability((prev) => ({ ...prev, [name]: false }));
      } finally {
        setChecking((prev) => ({ ...prev, [name]: false }));
      }
    }, 500);
  };

  const handleFieldChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    handleChange(e);
    const { name, value } = e.target;
    if (name === "email" || name === "username") checkAvailability(name, value);
    setMessage("");
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");

    const trimmed = getTrimmed();

    if (!isValidEmail(trimmed.email)) {
      setMessage("Please enter a valid email address.");
      return;
    }

    if (!isValidUsername(trimmed.username)) {
      setMessage("Username must be 3-30 characters (letters, numbers, underscores).");
      return;
    }

    if (!isStrongPassword(trimmed.password)) {
      setMessage("Password must be at least 8 characters and contain both letters and numbers.");
      return;
    }

    if (availability.email === false || availability.username === false) {
      setMessage("Email or username already exists.");
      return;
    }

    setSubmitting(true);

    try {
      const res = await fetch(`${import.meta.env.VITE_API_URL}/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(trimmed),
      });

      const data = await res.json();

      if (res.ok) {
        navigate("/login", {
          state: { flash: "🎉 Account created. Please log in." },
        });
      } else {
        setMessage(data.detail || "Registration failed.");
      }
    } catch {
      setMessage("An error occurred during registration.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#0a2a6c] bg-[url('/pattern.svg')] bg-cover bg-no-repeat flex flex-col items-center justify-center p-4">
      <Card className="w-full max-w-sm p-8">
        <div className="flex flex-col items-center justify-center text-center mb-4">
          <img src="/assets/kubeship-icon.svg" alt="KubeShip" className="w-10 h-10 mx-auto" />
          <h2 className="text-lg font-semibold mt-2 w-full">Create an Account</h2>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <InputField
            label="First Name"
            name="firstname"
            value={form.firstname}
            onChange={handleFieldChange}
            autoComplete="given-name"
            required
          />

          <InputField
            label="Last Name"
            name="lastname"
            value={form.lastname}
            onChange={handleFieldChange}
            autoComplete="family-name"
            required
          />

          <InputField
            label="Email"
            name="email"
            type="email"
            value={form.email}
            onChange={handleFieldChange}
            autoComplete="email"
            required
            showStatusIcon
            status={
              form.email.length === 0
                ? undefined
                : checking.email
                ? "checking"
                : availability.email
                ? "valid"
                : "invalid"
            }
          />

          <InputField
            label="Username"
            name="username"
            value={form.username}
            onChange={handleFieldChange}
            autoComplete="username"
            required
            showStatusIcon
            status={
              form.username.length === 0
                ? undefined
                : checking.username
                ? "checking"
                : availability.username
                ? "valid"
                : "invalid"
            }
          />

          <PasswordField
            label="Password"
            name="password"
            value={form.password}
            onChange={handleFieldChange}
            autoComplete="new-password"
            required
          />

          <Button
            type="submit"
            label={submitting ? "Registering..." : "Register"}
            disabled={
              submitting ||
              checking.email ||
              checking.username ||
              !isValidEmail(form.email) ||
              !isValidUsername(form.username) ||
              !isStrongPassword(form.password) ||
              availability.email === false ||
              availability.username === false
            }
            full
          />

          {message && (
            <p className="text-center text-sm text-red-600">{message}</p>
          )}
        </form>
      </Card>

      {/* Pill-style footer */}
      <div className="mt-6 bg-white/10 px-6 py-3 rounded-full text-white text-sm text-center">
        Already have an account?{" "}
        <a href="/login" className="font-bold underline">
          Sign In
        </a>
      </div>
    </div>
  );
};

export default Register;
