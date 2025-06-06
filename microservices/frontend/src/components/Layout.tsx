// kubeship/microservices/frontend/src/components/Layout.tsx

import React from "react";
import { Outlet, Link, useLocation, useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import { useAuth } from "../hooks/useAuth";

// ✅ Exported for use in Dashboard or other nested routes
export type LayoutContextType = {
  verifiedUser: any;
  handleLogout: () => void;
};

const Layout: React.FC = () => {
  const { user: verifiedUser, logout, loading } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-100 text-gray-700">
        <p>Checking session...</p>
      </div>
    );
  }

  return !verifiedUser ? (
    <Outlet context={{ verifiedUser: null, handleLogout: logout }} />
  ) : (
    <div className="min-h-screen bg-gray-100 p-4">
      <header className="bg-white shadow p-4 mb-6 flex justify-between items-center">
        <Link to="/dashboard" className="text-2xl font-bold text-blue-600 hover:underline">
          🚢 KubeShip Frontend
        </Link>

        <nav className="flex space-x-6 text-sm">
          <Link to="/dashboard" className="text-blue-600 hover:underline">Dashboard</Link>
          <Link to="/profile" className="text-blue-600 hover:underline">Profile</Link>
          <button onClick={logout} className="text-red-600 hover:underline">Logout</button>
        </nav>
      </header>

      <Outlet context={{ verifiedUser, handleLogout: logout }} />
    </div>
  );
};

export default Layout;
