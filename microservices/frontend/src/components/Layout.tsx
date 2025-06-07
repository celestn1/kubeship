// kubeship/microservices/frontend/src/components/Layout.tsx

import React from "react";
import { Outlet, Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

// ✅ Proper named export for useOutletContext
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
      <div className="flex items-center justify-center min-h-screen bg-[#0a2a6c] text-white">
        <p>Checking session...</p>
      </div>
    );
  }

  return !verifiedUser ? (
    // 🔓 Public layout (login, register)
    <div className="min-h-screen bg-[#0a2a6c] bg-[url('/pattern.svg')] bg-cover bg-no-repeat flex flex-col items-center justify-center p-4">
      <Outlet context={{ verifiedUser: null, handleLogout: logout }} />
    </div>
  ) : (
    // 🔐 Authenticated layout
    <div className="min-h-screen bg-[#0a2a6c] bg-[url('/pattern.svg')] bg-cover bg-no-repeat p-4 text-white flex justify-center">
      <div className="bg-white text-black rounded-lg shadow-md w-full max-w-6xl">
        
        {/* Header */}
        <header className="flex justify-between items-center px-6 py-4 border-b border-gray-200">
          <Link to="/dashboard" className="flex items-center space-x-2">
            <img src="/assets/kubeship-logo.svg" alt="KubeShip" className="h-6" />
          </Link>

          <nav className="flex space-x-6 text-sm">
            <Link to="/dashboard" className="text-gray-700 hover:text-blue-600">Dashboard</Link>
            <Link to="/profile" className="text-gray-700 hover:text-blue-600">Profile</Link>
            <button onClick={logout} className="text-red-600 hover:underline">Logout</button>
          </nav>
        </header>

        {/* Main Page Content */}
        <main className="p-6">
          <Outlet context={{ verifiedUser, handleLogout: logout }} />
        </main>
      </div>
    </div>
  );
};

export default Layout;
