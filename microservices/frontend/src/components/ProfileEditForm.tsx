// kubeship/microservices/frontend/src/components/ProfileEditForm.tsx

import React, { useState } from "react";

interface Props {
  initialBio: string;
  onSave: (bio: string, avatar: File | null) => void;
  onCancel: () => void;
}

const ProfileEditForm: React.FC<Props> = ({ initialBio, onSave, onCancel }) => {
  const [bio, setBio] = useState(initialBio);
  const [avatar, setAvatar] = useState<File | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(bio, avatar);
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white shadow rounded p-6 w-full max-w-xl mx-auto">
      <div className="mb-4">
        <label className="block text-sm font-semibold mb-1">Bio</label>
        <textarea
          value={bio}
          onChange={(e) => setBio(e.target.value)}
          className="w-full border rounded p-2"
          rows={3}
        />
      </div>

      <div className="mb-4">
        <label className="block text-sm font-semibold mb-1">Upload Avatar</label>
        <input type="file" onChange={(e) => setAvatar(e.target.files?.[0] || null)} />
      </div>

      <div className="flex justify-end space-x-3">
        <button type="button" onClick={onCancel} className="text-gray-600 hover:underline">Cancel</button>
        <button type="submit" className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600">
          Save
        </button>
      </div>
    </form>
  );
};

export default ProfileEditForm;
