// kubeship/microservices/frontend/src/components/ProfileView.tsx

import React from "react";

interface Props {
  user: string;
  email: string;
  bio: string;
  joined: string;
  onEdit: () => void;
}

const ProfileView: React.FC<Props> = ({ user, email, bio, joined, onEdit }) => (
  <div className="bg-white shadow rounded p-6 w-full max-w-xl mx-auto">
    <div className="text-center mb-4">
      <h2 className="text-xl font-bold">{user}</h2>
      <p className="text-sm text-gray-600">{bio || "No bio provided."}</p>
    </div>
    <div className="text-sm text-gray-700 space-y-2">
      <div><strong>Email:</strong> {email}</div>
      <div><strong>Member since:</strong> {joined}</div>
    </div>
    <div className="text-right mt-4">
      <button onClick={onEdit} className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
        Edit Profile
      </button>
    </div>
  </div>
);

export default ProfileView;
