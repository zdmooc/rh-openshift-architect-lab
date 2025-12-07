// scripts/build-preview.js
// Usage: node .\scripts\build-preview.js
// Output: preview.html (à la racine du repo)

const fs = require("fs");
const path = require("path");
const MarkdownIt = require("markdown-it");

const repo = path.resolve(__dirname, "..");
const bookPath = path.join(repo, "Book.txt");
const outPath = path.join(repo, "preview.html");

function normalizeHeadings(s) {
  // supprime les espaces/tabs avant les headings Markdown (sinon MarkdownIt les traite en paragraphe)
  return s.replace(/^[ \t]+(#{1,6}\s+)/gm, "$1");
}

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function stripExt(file) {
  return file.replace(/\.[^/.]+$/, "");
}

function slugify(s) {
  return String(s)
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[`~!@#$%^&*()+=\[\]{};:'"\\|,<.>/?]/g, " ")
    .replace(/\s+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function readBookList() {
  if (!fs.existsSync(bookPath)) throw new Error(`Book.txt introuvable: ${bookPath}`);
  return fs
    .readFileSync(bookPath, "utf8")
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith("#"));
}

const book = readBookList();

// TOC global + IDs uniques
const toc = [];
const globalIdCounts = new Map();
function uniqueId(base) {
  const n = (globalIdCounts.get(base) || 0) + 1;
  globalIdCounts.set(base, n);
  return n === 1 ? base : `${base}-${n}`;
}

function makeMdRenderer(fileKey) {
  const md = new MarkdownIt({ html: true, linkify: true, typographer: true });

  // Images -> <figure> + figcaption
  const defaultImage =
    md.renderer.rules.image ||
    function (tokens, idx, options, env, self) {
      return self.renderToken(tokens, idx, options);
    };

  md.renderer.rules.image = function (tokens, idx, options, env, self) {
    const token = tokens[idx];
    const alt = token.content || "";
    const rendered = defaultImage(tokens, idx, options, env, self);
    if (!alt.trim()) return rendered;
    return `<figure class="img-figure">${rendered}<figcaption>${escapeHtml(
      alt
    )}</figcaption></figure>`;
  };

  // Headings -> id + collecte TOC (H1/H2/H3)
  const origHeadingOpen =
    md.renderer.rules.heading_open ||
    function (tokens, idx, options, env, self) {
      return self.renderToken(tokens, idx, options);
    };

  md.renderer.rules.heading_open = function (tokens, idx, options, env, self) {
    const token = tokens[idx];
    const level = Number(token.tag.slice(1));
    const inline = tokens[idx + 1];
    const title = inline && inline.type === "inline" ? inline.content : "";

    if (title && level >= 1 && level <= 3) {
      const baseId = `${fileKey}-${slugify(title) || "section"}`;
      const id = uniqueId(baseId);
      token.attrSet("id", id);
      toc.push({ level, title, id });
    }
    return origHeadingOpen(tokens, idx, options, env, self);
  };

  return md;
}

let contentHtml = [];
for (const rel of book) {
  const full = path.resolve(repo, rel);
  if (!fs.existsSync(full)) throw new Error(`Fichier manquant (Book.txt): ${rel}`);

  const fileKey = slugify(stripExt(path.basename(rel))) || "file";

  let content = fs.readFileSync(full, "utf8");
  content = normalizeHeadings(content);

  const md = makeMdRenderer(fileKey);
  contentHtml.push(`<section class="chapter">`);
  contentHtml.push(md.render(content));
  contentHtml.push(`</section>`);
}

function buildTocHtml(items) {
  return items
    .map((it) => {
      const cls = it.level === 1 ? "l1" : it.level === 2 ? "l2" : "l3";
      return `<a class="toc-item ${cls}" href="#${it.id}" data-target="${it.id}" title="${escapeHtml(
        it.title
      )}">${escapeHtml(it.title)}</a>`;
    })
    .join("\n");
}

const html = `<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>EX280 Book Preview</title>
  <style>
    :root{
      --bg:#ffffff; --text:#111827; --muted:#6b7280;
      --border:#e5e7eb; --link:#2563eb; --linkHover:#1d4ed8;
      --sidebarBg:#ffffff; --shadow:0 1px 10px rgba(0,0,0,.06);
    }
    *{box-sizing:border-box}
    html{scroll-behavior:smooth}
    body{margin:0;font-family:Segoe UI,Arial,sans-serif;color:var(--text);background:var(--bg);line-height:1.6}

    .layout{
      display:grid;
      grid-template-columns: 340px minmax(0, 1fr);
      min-height:100vh;
    }

    /* Sidebar */
    .sidebar{
      position:sticky; top:0; height:100vh; overflow:auto;
      padding:18px 14px;
      background:var(--sidebarBg);
      border-right:1px solid var(--border);
      z-index:2;
    }
    .brand{font-weight:800;font-size:20px;margin:0 0 10px}
    .toc-title{margin:10px 0 8px;font-weight:700}
    .filter{
      width:100%;padding:8px 10px;border:1px solid var(--border);
      border-radius:10px;outline:none;margin:8px 0 12px;
    }
    .toc{display:flex;flex-direction:column;gap:4px;padding-bottom:14px}
    .toc-item{
      display:block;text-decoration:none;color:var(--link);
      padding:6px 10px;border-radius:10px;border:1px solid transparent;
      white-space:nowrap;overflow:hidden;text-overflow:ellipsis;line-height:1.25;
    }
    .toc-item:hover{color:var(--linkHover);background:#f8fafc;border-color:#e2e8f0}
    .toc-item.active{background:#eef2ff;border-color:#c7d2fe;color:#1e40af;font-weight:600}
    .toc-item.l1{margin-left:0}
    .toc-item.l2{margin-left:12px}
    .toc-item.l3{margin-left:24px;color:#1f6feb}

    /* Main: on centre le contenu dans la colonne pour éviter le “grand vide à droite” */
    .main{padding:28px 34px 60px;min-width:0}
    .content{max-width:1100px;margin:0 auto}
    .top{display:flex;align-items:flex-end;gap:10px;margin-bottom:22px}
    .top h1{margin:0;font-size:30px;letter-spacing:-0.02em}
    .top .meta{color:var(--muted);font-size:13px;margin-bottom:4px}

    hr{border:0;border-top:1px solid var(--border);margin:26px 0}
    pre{background:#f6f8fa;padding:12px;overflow:auto;border-radius:12px;border:1px solid #eef2f7}
    code{font-family:Consolas,ui-monospace,SFMono-Regular,Menlo,monospace}

    img{
      max-width:100%;height:auto;border:1px solid var(--border);
      padding:8px;border-radius:14px;background:#fff;box-shadow:var(--shadow)
    }
    .img-figure{margin:14px 0 18px}
    .img-figure figcaption{margin-top:8px;color:var(--muted);font-size:13px}

    h1,h2,h3{scroll-margin-top:16px}
    h1{font-size:28px;margin:26px 0 12px}
    h2{font-size:22px;margin:22px 0 10px}
    h3{font-size:18px;margin:18px 0 8px}
    .chapter{padding-bottom:8px}

    @media (max-width: 980px){
      .layout{grid-template-columns:1fr}
      .sidebar{position:relative;height:auto;border-right:0;border-bottom:1px solid var(--border)}
      .main{padding:18px 16px 50px}
      .content{max-width:unset}
    }
  </style>
</head>
<body>
  <div class="layout">
    <aside class="sidebar">
      <div class="brand">EX280 — Preview</div>
      <div class="toc-title">Sommaire</div>
      <input id="filter" class="filter" placeholder="Filtrer…" />
      <nav id="toc" class="toc">
        ${buildTocHtml(toc)}
      </nav>
    </aside>

    <main class="main">
      <div class="content">
        <div class="top">
          <h1>Lecture locale</h1>
          <div class="meta">preview.html (généré depuis Book.txt)</div>
        </div>

        ${contentHtml.join("\n<hr />\n")}
      </div>
    </main>
  </div>

  <script>
    (function(){
      const filter = document.getElementById("filter");
      const toc = document.getElementById("toc");
      const links = Array.from(toc.querySelectorAll(".toc-item"));

      // filtre TOC
      filter.addEventListener("input", () => {
        const q = filter.value.trim().toLowerCase();
        for (const a of links) {
          const ok = !q || a.textContent.toLowerCase().includes(q);
          a.style.display = ok ? "" : "none";
        }
      });

      // scroll doux + URL hash
      toc.addEventListener("click", (e) => {
        const a = e.target.closest("a.toc-item");
        if (!a) return;
        const id = a.getAttribute("data-target");
        const el = document.getElementById(id);
        if (!el) return;
        e.preventDefault();
        el.scrollIntoView({ behavior: "smooth", block: "start" });
        history.replaceState(null, "", "#" + id);
      });

      // highlight section active
      const headings = Array.from(document.querySelectorAll("h1[id], h2[id], h3[id]"));
      const byId = new Map(links.map(a => [a.getAttribute("data-target"), a]));

      function setActive(id){
        for (const a of links) a.classList.remove("active");
        const a = byId.get(id);
        if (a) a.classList.add("active");
      }

      if ("IntersectionObserver" in window) {
        const obs = new IntersectionObserver((entries) => {
          const visible = entries
            .filter(e => e.isIntersecting)
            .sort((a,b) => (b.intersectionRatio - a.intersectionRatio));
          if (visible[0]) setActive(visible[0].target.id);
        }, { threshold: [0.2, 0.35, 0.5, 0.7] });

        headings.forEach(h => obs.observe(h));
      }

      if (location.hash) setActive(location.hash.slice(1));
    })();
  </script>
</body>
</html>
`;

fs.writeFileSync(outPath, html, "utf8");
console.log("Generated preview.html");
