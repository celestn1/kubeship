// kubeship/microservices/frontend/src/pages/Register.tsx

import React, { useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { useFormInput } from "../hooks/useFormInput";

interface FormData {
  [key: string]: string;
  firstname: string;
  lastname: string;
  email: string;
  username: string;
  password: string;
}

const isValidEmail = (email: string): boolean =>
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

const Register: React.FC = () => {
  const { values: form, handleChange, getTrimmed } = useFormInput<FormData>({
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
    if ((name === "email" && !isValidEmail(value)) || value.trim() === "") {
      setAvailability((prev) => ({ ...prev, [name]: false }));
      setChecking((prev) => ({ ...prev, [name]: false }));
      return;
    }

    setChecking((prev) => ({ ...prev, [name]: true }));

    if (typingTimeout.current) clearTimeout(typingTimeout.current);

    typingTimeout.current = window.setTimeout(async () => {
      try {
        const res = await fetch(`${import.meta.env.VITE_API_URL}/check?${name}=${value}`);
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
      } else if (Array.isArray(data.detail)) {
        setMessage(data.detail[0]?.msg || "Validation error");
      } else {
        setMessage(data.detail || "Failed to register");
      }
    } catch {
      setMessage("An error occurred during registration");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-6">
      <form onSubmit={handleSubmit} className="bg-white p-8 rounded shadow-md w-full max-w-md">
        <h2 className="text-2xl font-bold text-center text-blue-700 mb-6">
          <a href="/" className="hover:underline">🚢 KubeShip Frontend</a>
        </h2>

        {["firstname", "lastname", "email", "username", "password"].map((field) => {
          const isEmail = field === "email";
          const isUsername = field === "username";
          const isPassword = field === "password";
          const value = (form as any)[field];

          const autocompleteMap: Record<string, string> = {
            firstname: "given-name",
            lastname: "family-name",
            email: "email",
            username: "username",
            password: "new-password"
          };

          return (
            <div key={field} className="mb-4">
              <label htmlFor={field} className="block text-sm font-medium mb-1 capitalize">{field}</label>
              <div className="relative">
                <input
                  type={isPassword ? "password" : isEmail ? "email" : "text"}
                  name={field}
                  id={field}
                  autoComplete={autocompleteMap[field]}
                  value={value}
                  onChange={handleFieldChange}
                  required
                  className={`w-full p-2 pr-10 border rounded focus:outline-none focus:ring-2 ${
                    isEmail && value && !isValidEmail(value)
                      ? "border-red-500 focus:ring-red-400"
                      : "focus:ring-blue-500"
                  }`}
                />
                {(isEmail || isUsername) && (
                  <div className="absolute right-2 top-2 text-sm">
                    {checking[field] ? (
                      <span className="text-gray-400 animate-pulse">⌛</span>
                    ) : isEmail && value && !isValidEmail(value) ? (
                      <span className="text-red-500">❌</span>
                    ) : availability[field] === true ? (
                      <span className="text-green-500">✅</span>
                    ) : availability[field] === false && value ? (
                      <span className="text-red-500">❌</span>
                    ) : null}
                  </div>
                )}
              </div>

              {isEmail && (
                <p className="text-xs text-gray-500 mt-1">
                  Enter a valid email like <i>name@example.com</i>
                </p>
              )}
              {isUsername && (
                <p className="text-xs text-gray-500 mt-1">
                  Choose a unique username (no spaces or special characters)
                </p>
              )}
              {isPassword && (
                <p className="text-xs text-gray-500 mt-1">
                  Password should be at least 8 characters long
                </p>
              )}
              {isEmail && value && !isValidEmail(value) && (
                <p className="text-sm text-red-500 mt-1">
                  Please enter a valid email format
                </p>
              )}
              {(isEmail || isUsername) &&
                availability[field] === false &&
                !checking[field] &&
                value &&
                isValidEmail(value) && (
                  <p className="text-sm text-red-500 mt-1">
                    {field.charAt(0).toUpperCase() + field.slice(1)} already in use
                  </p>
                )}
            </div>
          );
        })}

        <button
          type="submit"
          disabled={
            submitting ||
            checking.email ||
            checking.username ||
            !isValidEmail(form.email) ||
            availability.email === false ||
            availability.username === false
          }
          className="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded font-semibold disabled:opacity-50"
        >
          {submitting ? "Registering..." : "Register"}
        </button>

        <p className="mt-4 text-center text-sm">
          Already have an account?{" "}
          <a href="/login" className="text-blue-700 underline">Sign in</a>
        </p>

        {message && (
          <p className="mt-4 text-center text-sm text-red-600">{message}</p>
        )}
      </form>
    </div>
  );
};

export default Register;
