// Renders kit.json, which the build writes on every deploy.
const el = (tag, attrs = {}, ...children) => {
  const node = document.createElement(tag);
  for (const [key, value] of Object.entries(attrs)) {
    if (key === "class") node.className = value;
    else node.setAttribute(key, value);
  }
  for (const child of children.flat()) node.append(child);
  return node;
};

// Just enough markdown for AGENTS.md: headings, lists, paragraphs, inline code and bold.
const inline = (text) => {
  const span = el("span");
  span.innerHTML = text
    .replace(/&/g, "&amp;").replace(/</g, "&lt;")
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  return span;
};

const renderMarkdown = (md) => {
  const out = [];
  let list = null;
  for (const line of md.split("\n").slice(1)) {
    const heading = line.match(/^#{2,3}\s+(.*)/);
    const bullet = line.match(/^\s*(?:-|\d+\.)\s+(.*)/);
    if (heading) { list = null; out.push(el("h3", {}, heading[1])); }
    else if (bullet) {
      if (!list) { list = el(/^\s*\d/.test(line) ? "ol" : "ul"); out.push(list); }
      list.append(el("li", {}, inline(bullet[1])));
    } else if (line.trim()) { list = null; out.push(el("p", {}, inline(line))); }
  }
  return out;
};

const resultBadge = (result) => {
  if (result === "ok") return el("span", { class: "badge badge-result-ok" }, "passed");
  if (result === "warn") return el("span", { class: "badge badge-result-warn" }, "warning");
  if (result === "block") return el("span", { class: "badge badge-result-block" }, "failed");
  return el("span", { class: "badge badge-none" }, "not run");
};

const modeBadge = (mode) => el("span", { class: `badge badge-${mode}` }, mode === "block" ? "blocks" : "warns");

fetch("kit.json")
  .then((response) => response.json())
  .then((kit) => {
    const repoLink = kit.repository ? el("a", { href: `https://github.com/${kit.repository}` }, kit.repository) : "local build";
    [["Profile", kit.profile], ["Project", repoLink], ["Core", kit.core_version], ["Built", kit.built_at]]
      .forEach(([label, value]) => document.getElementById("meta").append(el("dt", {}, label), el("dd", {}, value || "–")));

    document.getElementById("skills-list").append(...kit.skills.map((skill) =>
      el("div", { class: "row" },
        el("h3", { class: "row-title" }, skill.name.replace(/-/g, " ")),
        el("p", { class: "row-text" }, skill.description),
        ...(skill.questions.length ? [el("details", {}, el("summary", {}, `The ${skill.questions.length} questions`), el("ol", {}, skill.questions.map((q) => el("li", {}, inline(q)))))] : []),
        el("details", {}, el("summary", {}, `${skill.steps.length} steps`), el("ol", {}, skill.steps.map((step) => el("li", {}, inline(step)))))
      )
    ));

    document.getElementById("checks-list").append(...kit.checks.map((check) =>
      el("div", { class: "row" },
        el("div", { class: "row-head" }, el("h3", { class: "row-title" }, check.check.replace(/-/g, " ").replace(/^ui /, "UI ")), el("div", { class: "row-badges" }, modeBadge(check.mode), resultBadge(check.result))),
        el("p", { class: "row-text" }, check.description),
        ...(check.message ? [el("p", { class: "row-message" }, check.message)] : [])
      )
    ));

    document.getElementById("profile-name").textContent = kit.profile;
    const names = Object.keys(kit.profiles);
    const allChecks = [...new Set(Object.values(kit.profiles).flat().map((row) => row.check))];
    const matrix = document.getElementById("matrix");
    matrix.append(el("thead", {}, el("tr", {}, el("th", {}, "Check"), names.map((name) => el("th", { class: name === kit.profile ? "current" : "" }, name)))));
    matrix.append(el("tbody", {}, allChecks.map((check) =>
      el("tr", {}, el("td", {}, check.replace(/-/g, " ").replace(/^ui /, "UI ")), names.map((name) => {
        const row = kit.profiles[name].find((r) => r.check === check);
        return el("td", {}, row ? modeBadge(row.mode) : "–");
      }))
    )));

    document.getElementById("rules-text").append(...renderMarkdown(kit.house_rules));
  })
  .catch(() => {
    document.getElementById("skills-list").append(el("p", { class: "muted" }, "Could not load kit.json. Run the build to generate it."));
  });
