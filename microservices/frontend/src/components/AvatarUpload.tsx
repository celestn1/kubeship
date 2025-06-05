// kubeship/microservices/frontend/src/components/AvatarUpload.tsx

import React, { useState } from "react";

interface AvatarUploadProps {
  onFileSelect: (file: File) => void;
  previewUrl?: string;
}

const AvatarUpload: React.FC<AvatarUploadProps> = ({ onFileSelect, previewUrl }) => {
  const [preview, setPreview] = useState(previewUrl || "");

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setPreview(URL.createObjectURL(file));
      onFileSelect(file);
    }
  };

  return (
    <div className="text-center mb-4">
      <div className="w-24 h-24 mx-auto rounded-full overflow-hidden border">
        <img
          src={preview || "/default-avatar.png"}
          alt="User avatar"
          className="w-full h-full object-cover"
        />
      </div>
      <input type="file" className="mt-2" onChange={handleChange} />
    </div>
  );
};

export default AvatarUpload;
