// kubeship/microservices/frontend/src/components/Form/InputField.tsx

import React from "react";

interface InputFieldProps {
  label: string;
  name: string;
  type?: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  error?: string;
  helperText?: string;
  autoComplete?: string;
  showStatusIcon?: boolean;
  status?: "checking" | "valid" | "invalid";
  required?: boolean;
  icon?: React.ReactNode;
  placeholder?: string;
}

const InputField: React.FC<InputFieldProps> = ({
  label,
  name,
  type = "text",
  value,
  onChange,
  error,
  helperText,
  autoComplete,
  showStatusIcon = false,
  status,
  required,
  icon,
}) => {
  const renderStatusIcon = () => {
    if (!showStatusIcon) return null;

    switch (status) {
      case "checking":
        return <span className="text-gray-400 animate-pulse">⌛</span>;
      case "valid":
        return <span className="text-green-500">✅</span>;
      case "invalid":
        return <span className="text-red-500">❌</span>;
      default:
        return null;
    }
  };

  return (
    <div className="mb-4">
      <label htmlFor={name} className="block text-sm font-medium mb-1 capitalize">
        {label}
      </label>

      <div className="relative">
        {icon && (
          <div className="absolute inset-y-0 left-2 flex items-center text-gray-400">
            {icon}
          </div>
        )}

        <input
          type={type}
          id={name}
          name={name}
          value={value}
          onChange={onChange}
          autoComplete={autoComplete}
          required={required}
          className={`w-full p-2 ${icon ? "pl-10" : ""} pr-10 border rounded focus:outline-none focus:ring-2 ${
            error ? "border-red-500 focus:ring-red-400" : "focus:ring-blue-500"
          }`}
        />

        <div className="absolute right-2 top-2 text-sm">{renderStatusIcon()}</div>
      </div>

      {helperText && <p className="text-xs text-gray-500 mt-1">{helperText}</p>}
      {error && <p className="text-sm text-red-500 mt-1">{error}</p>}
    </div>
  );
};

export default InputField;
