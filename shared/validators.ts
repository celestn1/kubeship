// kubeship/shared/validators.ts

export const USERNAME_REGEX = /^[a-zA-Z0-9_]{3,30}$/;

export const isValidUsername = (username: string): boolean => {
  return USERNAME_REGEX.test(username.trim());
};

export const isValidEmail = (email: string): boolean => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim());
};

export const isStrongPassword = (password: string): boolean => {
  return (
    typeof password === "string" &&
    password.length >= 8 &&
    /[A-Za-z]/.test(password) &&
    /[0-9]/.test(password)
    // optionally: include symbol check
    // && /[@$!%*#?&]/.test(password)
  );
};
