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

  const currentWorkingDirectory = process.cwd();
  const directoryName = path.basename(currentWorkingDirectory);

  if (appName !== "." && fs.existsSync(appPath)) {
    console.log(
      chalk.redBright(`[FAIL] Folder "${appName}" already exists. Choose a different name or remove the folder.\n`)
    );
    return;
  }

  const displayName = appName === "." ? directoryName : appName;
  console.log(chalk.cyan(`[INFO] Creating React + Vite project: ${displayName}`));

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
    <h1 className="text-3xl font-bold underline bg-slate-600 h-screen p-3">
      React + Vite + Tailwind — DevEnvx Setup
    </h1>
  );
}`;
  fs.writeFileSync(path.join(appPath, "src/App.jsx"), appJsx);

  // Minimal index.css with Tailwind directives
  fs.writeFileSync(path.join(appPath, "src/index.css"), `@import "tailwindcss";`);

  console.log(chalk.cyan("[INFO] Installing TailwindCSS v4.1"));
  try {
    execSync("npm install tailwindcss @tailwindcss/vite", { stdio: "inherit" });
  } catch {
    console.log(chalk.red("[FAIL] Could not install TailwindCSS dependencies."));
    return;
  }

  console.log(chalk.cyan("\n[INFO] Configuring TailwindCSS + Vite plugin..."));

  // Write tailwind.config.js (keep it minimal for future customization)
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

  // Write vite.config.js (overwrite, no replacing)
  const viteConfigPath = path.join(appPath, "vite.config.js");
  const viteConfig = `import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
  ],
})
`;
  fs.writeFileSync(viteConfigPath, viteConfig);

  console.log(chalk.cyan("[INFO] Updated tailwind.config.js and vite.config.js"));

  console.log(chalk.greenBright("\n[SUCCESS] React + Vite + Tailwind v4.1 setup complete!"));
  
  console.log(chalk.white("\nDone. Now run the following commands:"));
  if (appName !== ".") {
    console.log(chalk.white(`  cd ${appName}`));
  }
  console.log(chalk.white("  npm install"));
  console.log(chalk.white("  npm run dev\n"));
}
