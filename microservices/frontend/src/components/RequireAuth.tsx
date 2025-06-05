// kubeship/microservices/frontend/src/components/RequireAuth.tsx

import React from "react";
import { Navigate, useLocation, useOutletContext } from "react-router-dom";

type ContextType = { verifiedUser: string | null };

const RequireAuth = ({ children }: { children: JSX.Element }) => {
  const location = useLocation();
  const { verifiedUser } = useOutletContext<ContextType>();

  if (!verifiedUser) {
    return <Navigate to="/" state={{ from: location }} replace />;
  }

  return children;
};

export default RequireAuth;
