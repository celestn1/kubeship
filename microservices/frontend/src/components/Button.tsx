// kubeship/microservices/frontend/src/components/Button.tsx
import React from "react";

interface ButtonProps {
  label: string;
  onClick: () => void;
  color?: "green" | "blue" | "red";
}

const Button: React.FC<ButtonProps> = ({ label, onClick, color = "blue" }) => {
  const base = "text-white px-4 py-2 rounded";
  const colors = {
    green: "bg-green-500 hover:bg-green-600",
    blue: "bg-blue-500 hover:bg-blue-600",
    red: "bg-red-500 hover:bg-red-600",
  };
  return (
    <button onClick={onClick} className={`${colors[color]} ${base}`}>
      {label}
    </button>
  );
};

export default Button;