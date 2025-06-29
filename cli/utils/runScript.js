import { spawn } from 'child_process';

export function runScript(scriptPath, lang) {
  return new Promise((resolve, reject) => {
    const child = spawn('powershell', [
      '-ExecutionPolicy', 'Bypass',
      '-File', scriptPath
    ], { stdio: 'inherit' });

    child.on('close', (code) => {
      if (code !== 0) {
        console.error(`\n❌ Error installing ${lang}`);
        return reject(new Error(`Exited with code ${code}`));
      }
      resolve();
    });
  });
}
