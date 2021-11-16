const { spawnSync } = require("child_process");

const watch = require("node-watch");

console.log("Waiting for file changes...");

spawnSync("yarn", ["build"]);

watch("src", { recursive: true }, (_, name) => {
  // inform user that a file being watched changed
  console.log(`${name} changed. Re-running build...`);

  // rebuild
  const { status, stderr } = spawnSync("yarn", ["build"], {
    encoding: "utf-8",
  });

  // make sure we inform user that their build was successful
  if (status === 0) {
    console.log("Built successfully.");
  } else {
    console.error("Something went wrong:");
    console.error(stderr);
  }
});
