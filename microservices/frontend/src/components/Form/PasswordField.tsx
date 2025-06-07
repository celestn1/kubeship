// kubeship/microservices/frontend/src/components/Form/PasswordField.tsx

import React, { useState } from "react";
import { Lock, Eye, EyeOff } from "lucide-react";

interface PasswordFieldProps {
  name: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  autoComplete?: string;
  required?: boolean;
  placeholder?: string;
  label?: string;
  helperText?: string;
}

const PasswordField: React.FC<PasswordFieldProps> = ({
  name,
  value,
  onChange,
  autoComplete,
  required = false,
  placeholder = "Password",
  label,
}) => {
  const [show, setShow] = useState(false);

  return (
    <div className="mb-4">
      {label && <label htmlFor={name} className="block mb-1 text-sm font-medium">{label}</label>}

      <div className="relative">
        <span className="absolute inset-y-0 left-3 flex items-center text-gray-400">
          <Lock size={16} />
        </span>

        <input
          id={name}
          name={name}
          type={show ? "text" : "password"}
          value={value}
          onChange={onChange}
          autoComplete={autoComplete}
          required={required}
          placeholder={placeholder}
          className="w-full pl-10 pr-10 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
        />

        <button
          type="button"
          onClick={() => setShow((prev) => !prev)}
          className="absolute inset-y-0 right-3 flex items-center text-gray-400"
        >
          {show ? <EyeOff size={16} /> : <Eye size={16} />}
        </button>
      </div>
    </div>
  );
};

export default PasswordField;
