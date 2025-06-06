// kubeship/microservices/frontend/src/components/Form/AvatarUpload.tsx

import React, { useRef, useState } from "react";

interface AvatarUploadProps {
  onUpload: (file: File) => void;
  label?: string;
}

const AvatarUpload: React.FC<AvatarUploadProps> = ({ onUpload, label = "Upload Avatar" }) => {
  const fileRef = useRef<HTMLInputElement>(null);
  const [preview, setPreview] = useState<string | null>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const url = URL.createObjectURL(file);
      setPreview(url);
      onUpload(file);
    }
  };

  return (
    <div className="flex flex-col items-center space-y-2">
      {preview && (
        <img
          src={preview}
          alt="Preview"
          className="w-24 h-24 rounded-full object-cover border border-gray-300"
        />
      )}
      <input
        type="file"
        accept="image/*"
        className="hidden"
        ref={fileRef}
        onChange={handleFileChange}
      />
      <button
        type="button"
        onClick={() => fileRef.current?.click()}
        className="text-sm text-blue-600 underline hover:text-blue-800"
      >
        {label}
      </button>
    </div>
  );
};

export default AvatarUpload;
