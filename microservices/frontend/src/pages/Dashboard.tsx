// kubeship/microservices/frontend/src/pages/Dashboard.tsx

import React from "react";
import { useOutletContext } from "react-router-dom";
import Card from "../components/Card";
import Button from "../components/Button";
import { LayoutContextType } from "../components/Layout";

const Dashboard: React.FC = () => {
  const { verifiedUser, handleLogout } = useOutletContext<LayoutContextType>();

  return (
    <Card>
      <div className="text-center">
        <h2 className="text-xl font-semibold mb-2">
          Welcome{verifiedUser ? `, ${verifiedUser}` : ""}!
        </h2>
        <p className="text-sm text-gray-600 mb-4">You are logged in and verified ✅</p>
        <Button label="Logout" onClick={handleLogout} color="red" />
      </div>
    </Card>
  );
};

export default Dashboard;