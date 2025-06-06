// kubeship/microservices/frontend/src/components/UI/Card.tsx

import React from "react";

interface CardProps {
  children: React.ReactNode;
  className?: string;
}

const Card: React.FC<CardProps> = ({ children, className = "" }) => {
  return (
    <div className={`bg-white shadow-md rounded p-6 ${className}`}>
      {children}
    </div>
  );
};

export default Card;
