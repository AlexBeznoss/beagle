import ClerkLib from "@clerk/clerk-js";

export async function initClerk() {
  const token = document.querySelector('meta[name="clerk-token"]').content;
  const clerk = new ClerkLib.default(token);
  await clerk.load();

  return clerk;
}
