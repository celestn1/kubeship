// kubeship/microservices/frontend/src/hooks/useFormInput.ts

import { useState } from "react";

type InputEvent = React.ChangeEvent<HTMLInputElement>;

export const useFormInput = <T extends Record<string, string>>(initialValues: T) => {
  const [values, setValues] = useState<T>(initialValues);

  const handleChange = (e: InputEvent) => {
    const { name, value } = e.target;
    setValues((prev) => ({ ...prev, [name]: value }));
  };

  const getTrimmed = (): T => {
    const trimmed: Partial<T> = {};
    for (const key in values) {
      trimmed[key] = values[key].trim() as T[Extract<keyof T, string>];
    }
    return trimmed as T;
  };

  const reset = () => setValues(initialValues);

  return { values, handleChange, getTrimmed, reset };
};
