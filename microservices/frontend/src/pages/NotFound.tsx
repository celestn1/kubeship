// kubeship/microservices/frontend/src/pages/NotFound.tsx

import React from "react";
import { Link } from "react-router-dom";
import Card from "../components/UI/Card";

const NotFound: React.FC = () => {
  const handleReportBug = () => {
    const subject = encodeURIComponent("Bug Report: 404 Page");
    const body = encodeURIComponent(
      `Hi KubeShip team,%0D%0A%0D%0AI encountered a broken link or missing page at:%0D%0A${window.location.href}%0D%0A%0D%0AExpected Behavior:%0D%0ADescribe what you expected to happen...%0D%0A%0D%0AThanks!`
    );
    window.location.href = `mailto:support@kubeship.io?subject=${subject}&body=${body}`;
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-6">
      <Card>
        <div className="text-center space-y-4">
          <h1 className="text-4xl font-bold text-red-600">404 - Page Not Found</h1>
          <p className="text-gray-700 max-w-md mx-auto">
            The page you are looking for doesn't exist or has been moved. Please check the URL or return to the home page.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link to="/" className="text-blue-600 hover:underline font-medium">
              ← Back to Home
            </Link>
            <button
              onClick={handleReportBug}
              className="text-sm text-red-500 underline hover:text-red-700"
            >
              Report this bug
            </button>
          </div>
        </div>
      </Card>
    </div>
  );
};

export default NotFound;
