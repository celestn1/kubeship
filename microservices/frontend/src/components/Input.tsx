// kubeship/microservices/frontend/src/components/Input.tsx
import React from "react";

interface InputProps {
  type: string;
  placeholder: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

const Input: React.FC<InputProps> = ({ type, placeholder, value, onChange }) => (
  <input
    type={type}
    placeholder={placeholder}
    className="w-full mb-3 p-2 border rounded"
    value={value}
    onChange={onChange}
  />
);

export default Input;