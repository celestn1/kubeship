// kubeship/microservices/frontend/src/hooks/useFormInput.ts

import { useState } from "react";

export const useFormInput = <T extends Record<string, string>>(initial: T) => {
  const [values, setValues] = useState<T>(initial);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    const trimmedStart = value.trimStart();
    setValues((prev) => ({ ...prev, [name]: trimmedStart }));
  };

  const getTrimmed = (): T => {
    const result = {} as T;
    for (const key in values) {
      result[key] = values[key].trim() as T[Extract<keyof T, string>];
    }
    return result;
  };

  return {
    values,
    handleChange,
    getTrimmed,
    setValues,
  };
};
