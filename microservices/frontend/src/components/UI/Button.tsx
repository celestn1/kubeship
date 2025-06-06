// kubeship/microservices/frontend/src/components/UI/Button.tsx

import React from "react";

interface ButtonProps {
  type?: "button" | "submit" | "reset";
  label: string;
  onClick?: () => void;
  color?: "blue" | "red" | "gray";
  disabled?: boolean;
  full?: boolean;
  fullWidth?: boolean;
}

const Button: React.FC<ButtonProps> = ({
  type = "button",
  label,
  onClick,
  color = "blue",
  disabled = false,
  full = false,
  fullWidth = true,
}) => {
  const colorClasses = {
    blue: "bg-blue-600 hover:bg-blue-700 text-white",
    red: "bg-red-600 hover:bg-red-700 text-white",
    gray: "bg-gray-300 hover:bg-gray-400 text-black",
  };

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={`
        ${colorClasses[color]}
        ${fullWidth ? "w-full" : ""}
        py-2 px-4 rounded font-semibold
        disabled:opacity-50 transition duration-200
      `}
    >
      {label}
    </button>
  );
};

export default Button;
