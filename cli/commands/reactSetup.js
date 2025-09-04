import { execSync } from "child_process";
import fs from "fs";
import path from "path";
import chalk from "chalk";

export async function setupReact(appName) {
  if (!appName) {
    console.log(chalk.red("[FAIL] Please provide an app name!"));
    return;
  }

  const appPath = appName === "." ? process.cwd() : path.join(process.cwd(), appName);

  if (appName !== "." && fs.existsSync(appPath)) {
    console.log(chalk.red(`[FAIL] Folder "${appName}" already exists!`));
    return;
  }

  console.log(chalk.cyan(`[INFO] Creating React + Vite project: ${appName}`));
  try {
    const targetArg = appName === "." ? "." : appName;
    execSync(`npm create vite@latest ${targetArg} -- --template react`, { stdio: "inherit" });
  } catch {
    console.log(chalk.red("[FAIL] Failed to create Vite project."));
    return;
  }

  process.chdir(appPath);

  console.log(chalk.cyan("[INFO] Cleaning unnecessary files..."));
  ["src/App.css", "src/index.css", "src/logo.svg"].forEach((file) => {
    const filePath = path.join(appPath, file);
    if (fs.existsSync(filePath)) fs.rmSync(filePath);
  });

  // Minimal App.jsx
  const appJsx = `export default function App() {
  return (
    <h1 className="text-3xl font-bold underline">
      Hello world
    </h1>
  );
}
`;
  fs.writeFileSync(path.join(appPath, "src/App.jsx"), appJsx);

  // Minimal index.css with Tailwind directives
  fs.writeFileSync(path.join(appPath, "src/index.css"), `@tailwind base;
@tailwind components;
@tailwind utilities;
`);

  console.log(chalk.cyan("[INFO] Installing TailwindCSS v3.4.17..."));
  try {
    execSync("npm install -D tailwindcss@3.4.17 postcss autoprefixer", { stdio: "inherit" });
  } catch {
    console.log(chalk.red("[FAIL] Could not install TailwindCSS dependencies."));
    return;
  }

  console.log(chalk.cyan("\n[INFO] Initializing TailwindCSS config..."));
  try {
    execSync("npx tailwindcss init -p", { stdio: "inherit" });
  } catch {
    console.log(chalk.red("[FAIL] Could not initialize TailwindCSS config."));
    return;
  }

  // Update tailwind.config.js content
  const tailwindConfigPath = path.join(appPath, "tailwind.config.js");
  const tailwindConfig = `/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
`;
  fs.writeFileSync(tailwindConfigPath, tailwindConfig);

  console.log(chalk.greenBright("\n[SUCCESS] React + Vite + Tailwind v3.4.17 setup complete!"));
  console.log(chalk.greenBright(`[INFO] cd ${appName === "." ? "." : appName} && npm run dev`));
}
