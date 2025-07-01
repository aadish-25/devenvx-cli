// Purpose of runScript.js:
// Run the given PowerShell script, show its output in real-time, wait for it to finish, and handle any errors or startup failures.

// Importing the 'spawn' function from Node's built-in 'child_process' module.
// This is used to create a child process to run external commands/scripts.
// In this case, it allows us to run PowerShell scripts from our Node.js app.
import { spawn } from 'child_process';

export function runScript(scriptPath) {
  return new Promise((resolve, reject) => {

    // Create (spawn) a new process to run PowerShell.
    // The 'Bypass' policy makes sure Windows doesn't block the script.
    const child = spawn('powershell.exe', [
      '-ExecutionPolicy', 'Bypass',
      '-File', scriptPath
    ], {
      // Show script output live in the terminal.
      stdio: 'inherit'
    });

    // This runs when the PowerShell script finishes.
    child.on('close', (code) => {
      // If script exits with code 0 (success), resolve the promise.
      if (code === 0) {
        resolve();
      }
      // If it exits with any other code (error), reject the promise.
      else {
        reject({ code });
      }
    });

    // This runs if PowerShell fails to start (e.g., not installed or blocked).
    child.on('error', (err) => {
      console.error(`\n[CRASH] Failed to start PowerShell: ${err.message}`);
      reject({ code: -1 });
    });
  });
}
