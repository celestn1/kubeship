// kubeship/microservices/frontend/src/pages/Profile.tsx

import React, { useState } from "react";
import { useOutletContext } from "react-router-dom";
import AvatarUpload from "../components/AvatarUpload";
import ProfileView from "../components/ProfileView";
import ProfileEditForm from "../components/ProfileEditForm";

const Profile = () => {
  const { verifiedUser } = useOutletContext<{ verifiedUser: string | null }>();
  const [isEditing, setIsEditing] = useState(false);

  const handleSave = async (bio: string, avatar: File | null) => {
    // Send PATCH/PUT to your API here
    console.log("Saving...", bio, avatar);
    setIsEditing(false);
  };

  if (!verifiedUser) {
    return <p className="text-center text-red-600">User not logged in</p>;
  }

  return isEditing ? (
    <ProfileEditForm
      initialBio="" 
      onSave={handleSave}
      onCancel={() => setIsEditing(false)}
    />
  ) : (
    <ProfileView
      user={verifiedUser}
      email=""
      bio=""
      joined=""
      onEdit={() => setIsEditing(true)}
    />
  );
};

export default Profile;
