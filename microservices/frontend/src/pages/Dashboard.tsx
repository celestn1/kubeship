// kubeship/microservices/frontend/src/pages/Dashboard.tsx

import React from "react";
import { useOutletContext } from "react-router-dom";
import Card from "../components/UI/Card";
import Button from "../components/UI/Button";

type LayoutContextType = {
  verifiedUser: string | null;
  handleLogout: () => void;
};

const Dashboard: React.FC = () => {
  const { verifiedUser, handleLogout } = useOutletContext<LayoutContextType>();

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-6">
      <Card>
        <div className="text-center space-y-4">
          <h2 className="text-xl font-semibold text-gray-800">
            Welcome{verifiedUser ? `, ${verifiedUser}` : ""}!
          </h2>
          <p className="text-sm text-gray-600">You are logged in and verified ✅</p>
          <Button label="Logout" onClick={handleLogout} color="red" />
        </div>
      </Card>
    </div>
  );
};

export default Dashboard;
