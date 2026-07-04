import { redirect } from "next/navigation";

// The middleware bounces unauthenticated users to /login, so authenticated users
// landing on "/" go straight to the dashboard.
export default function Home() {
  redirect("/dashboard");
}
