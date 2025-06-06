// kubeship/microservices/frontend/src/pages/Profile.tsx

import React from "react";
import { useOutletContext } from "react-router-dom";
import Card from "../components/UI/Card";
import Button from "../components/UI/Button";

type LayoutContextType = {
  verifiedUser: string | null;
  handleLogout: () => void;
};

const Profile: React.FC = () => {
  const { verifiedUser, handleLogout } = useOutletContext<LayoutContextType>();

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-6">
      <Card>
        <div className="space-y-4 text-center">
          <h2 className="text-xl font-semibold text-gray-800">
            Profile Information
          </h2>
          <p className="text-sm text-gray-600">
            Logged in as: <span className="font-medium">{verifiedUser}</span>
          </p>
          <Button label="Logout" onClick={handleLogout} color="red" />
        </div>
      </Card>
    </div>
  );
};

export default Profile;
