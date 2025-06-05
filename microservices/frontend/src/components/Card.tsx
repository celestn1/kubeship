// kubeship/microservices/frontend/src/components/Card.tsx
import React from "react";

const Card: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div className="bg-white shadow-md rounded p-6 w-full max-w-md text-center">
    {children}
  </div>
);

export default Card;