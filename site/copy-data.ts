// pre-render: publish the version 06 package files (../inst/extdata) at data/v06/
const src = "../inst/extdata";
const dest = "data/v06";
Deno.mkdirSync(dest, { recursive: true });
for (const entry of Deno.readDirSync(src)) {
  if (entry.isFile && entry.name.startsWith("measo_regions06")) {
    Deno.copyFileSync(`${src}/${entry.name}`, `${dest}/${entry.name}`);
  }
}
