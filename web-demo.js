// MEASO regions in the browser: MapLibre map, planar region lookup, DuckDB-Wasm query.
// Used by web.qmd; the data are read from the published files next to this page.
const base = new URL("data/v06/", document.baseURI).href;
const regions = await (await fetch(base + "measo_regions06_ll.geojson")).json();

// ---- map ----
const map = new maplibregl.Map({
  container: "measo-map",
  style: {version: 8, sources: {},
          layers: [{id: "background", type: "background", paint: {"background-color": "#f4f6f8"}}]},
  center: [0, -55], zoom: 0.7, renderWorldCopies: false, attributionControl: false
});
map.on("load", async () => {
  map.addSource("regions", {type: "geojson", data: regions});
  map.addLayer({id: "regions-fill", type: "fill", source: "regions",
                paint: {"fill-color": ["coalesce", ["get", "fill"], "rgba(0,0,0,0)"]}});
  map.addLayer({id: "regions-line", type: "line", source: "regions",
                paint: {"line-color": "#555", "line-width": 0.6}});
  try {
    const topojson = await import("https://cdn.jsdelivr.net/npm/topojson-client@3/+esm");
    const world = await (await fetch("https://cdn.jsdelivr.net/npm/world-atlas@2/land-110m.json")).json();
    map.addSource("land", {type: "geojson", data: topojson.feature(world, world.objects.land)});
    map.addLayer({id: "land", type: "fill", source: "land", paint: {"fill-color": "#999"}});
  } catch (e) { console.warn("land layer not loaded", e); }
});
map.on("click", "regions-fill", e => {
  const p = e.features[0].properties;
  new maplibregl.Popup().setLngLat(e.lngLat)
    .setHTML(`<b>${p.label}</b> (${p.name})${p.zone ? "" : "<br>outside MEASO"}`).addTo(map);
});

// ---- region lookup: planar point-in-polygon in longitude/latitude ----
function inRing([x, y], ring) {
  let inside = false;
  for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    const [xi, yi] = ring[i], [xj, yj] = ring[j];
    if ((yi > y) !== (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) inside = !inside;
  }
  return inside;
}
const inPolygon = (p, rings) => inRing(p, rings[0]) && !rings.slice(1).some(h => inRing(p, h));
const contains = (geom, p) =>
  (geom.type === "Polygon" ? [geom.coordinates] : geom.coordinates).some(rings => inPolygon(p, rings));

const lon = document.getElementById("measo-lon"), lat = document.getElementById("measo-lat");
function lookup() {
  const p = [Number(lon.value), Number(lat.value)];
  const hit = regions.features.find(f => contains(f.geometry, p));
  document.getElementById("measo-lonlat").textContent = `${p[0]}, ${p[1]}`;
  document.getElementById("measo-hit").innerHTML = hit
    ? `<b>${hit.properties.label}</b> (${hit.properties.name})${hit.properties.zone ? "" : ", outside MEASO"}`
    : "(none)";
}
lon.addEventListener("input", lookup); lat.addEventListener("input", lookup);
lookup();

// ---- DuckDB-Wasm: query the GeoParquet file from its URL ----
const out = document.getElementById("measo-table");
try {
  const duckdb = await import("https://cdn.jsdelivr.net/npm/@duckdb/duckdb-wasm@1.29.0/+esm");
  const bundle = await duckdb.selectBundle(duckdb.getJsDelivrBundles());
  const workerUrl = URL.createObjectURL(
    new Blob([`importScripts("${bundle.mainWorker}");`], {type: "text/javascript"}));
  const db = new duckdb.AsyncDuckDB(new duckdb.ConsoleLogger(duckdb.LogLevel.WARNING), new Worker(workerUrl));
  await db.instantiate(bundle.mainModule, bundle.pthreadWorker);
  const conn = await db.connect();
  const sql = `SELECT name, label, fill FROM read_parquet('${base}measo_regions06_ll.parquet')`;
  const rows = (await conn.query(sql)).toArray().map(r => r.toJSON());
  out.innerHTML = `<pre><code>${sql}</code></pre><table class="table table-sm"><thead><tr>` +
    Object.keys(rows[0]).map(k => `<th>${k}</th>`).join("") + "</tr></thead><tbody>" +
    rows.map(r => "<tr>" + Object.values(r).map(v => `<td>${v ?? ""}</td>`).join("") + "</tr>").join("") +
    "</tbody></table>";
} catch (e) {
  out.textContent = "DuckDB-Wasm could not be loaded: " + e;
}
