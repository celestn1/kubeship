// kubeship/microservices/frontend/src/components/Form/PasswordField.tsx

import React, { useState } from "react";

interface PasswordFieldProps {
  label: string;
  name: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  error?: string;
  helperText?: string;
  autoComplete?: string;
  required?: boolean; // ✅ Added to support <PasswordField required />
}

const PasswordField: React.FC<PasswordFieldProps> = ({
  label,
  name,
  value,
  onChange,
  error,
  helperText,
  autoComplete = "new-password",
  required = false, // ✅ Defaults to false
}) => {
  const [showPassword, setShowPassword] = useState(false);

  return (
    <div className="mb-4">
      <label htmlFor={name} className="block text-sm font-medium mb-1 capitalize">
        {label}
      </label>

      <div className="relative">
        <input
          type={showPassword ? "text" : "password"}
          id={name}
          name={name}
          value={value}
          onChange={onChange}
          autoComplete={autoComplete}
          required={required}
          className={`w-full p-2 pr-16 border rounded focus:outline-none focus:ring-2 ${
            error ? "border-red-500 focus:ring-red-400" : "focus:ring-blue-500"
          }`}
        />
        <button
          type="button"
          onClick={() => setShowPassword(!showPassword)}
          className="absolute inset-y-0 right-2 flex items-center text-sm text-blue-600 hover:underline"
        >
          {showPassword ? "Hide" : "Show"}
        </button>
      </div>

      {helperText && <p className="text-xs text-gray-500 mt-1">{helperText}</p>}
      {error && <p className="text-sm text-red-500 mt-1">{error}</p>}
    </div>
  );
};

export default PasswordField;
