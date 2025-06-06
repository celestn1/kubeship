// kubeship/microservices/frontend/src/hooks/useFlashMessage.ts

import { useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import toast from "react-hot-toast";

export const useFlashMessage = () => {
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    const flash = location.state?.flash;
    if (flash) {
      toast.dismiss();
      toast.success(flash);
      navigate(location.pathname, { replace: true, state: {} });
    }
  }, [location.key]);
};
