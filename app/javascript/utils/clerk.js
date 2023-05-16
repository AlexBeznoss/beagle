export function waitForClerk() {
  const isReady = () => window.Clerk && window.Clerk.isReady();

  return new Promise((resolve) => {
    const interval = setInterval(() => {
      if (isReady()) {
        resolve();
        clearInterval(interval);
      }
    }, 50);
  })
}
