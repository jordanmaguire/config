// Start work: an optional GitHub issue or pull request (14315, #14315 or its
// URL) and a description of what to do; at least one. An issue, or a description
// alone, gets a new branch and worktree from the remote default branch; a pull
// request gets a worktree on its own branch. Then a space on it with Claude on
// the left and a shell on the right.

import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { run, props, closeOverlay, theme, spaces, panes, exec, home, appHome, readTextFile } from "herdr";

// Used when the focused terminal is not inside a git repository.
const FALLBACK_REPO = "src/interexchange/app";
const AGENT = ["claude"];
const BRANCH_MAX = 60;

const kebab = (text) =>
  text.normalize("NFKD").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "")
    .slice(0, BRANCH_MAX).replace(/-+$/, "");

// An issue or pull request number from "14315", "#14315" or a GitHub issue or
// pull request URL; else null. GitHub numbers both from one sequence, so the
// number alone says which it is once looked up.
const issueNumber = (text) => text.match(/^#?(\d+)$/)?.[1] ?? text.match(/github\.com\/[^/]+\/[^/]+\/(?:issues|pull)\/(\d+)/)?.[1] ?? null;

async function git(cwd, args, timeout = 30_000) {
  const r = await exec("git", args, { cwd, timeout });
  return { ok: r.code === 0, out: (r.stdout ?? "").trim(), err: (r.stderr || r.stdout || "").trim() };
}

// The main checkout of the repo a folder belongs to, or null outside git.
async function mainCheckout(folder) {
  if (!folder) return null;
  try {
    const common = await git(folder, ["rev-parse", "--path-format=absolute", "--git-common-dir"]);
    if (!common.ok) return null;
    return common.out.endsWith("/.git") ? common.out.slice(0, -5) : common.out;
  } catch { return null; }
}

async function worktreeRoot() {
  const raw = await readTextFile(`${appHome()}/settings.json`);
  const directory = (raw === null ? {} : JSON.parse(raw))?.worktrees?.directory ?? "~/.herdr/worktrees";
  return (directory.startsWith("~") ? home() + directory.slice(1) : directory).replace(/\/+$/, "");
}

export default class StartWork extends View {
  init(_props, cx) {
    this.error = "";
    this.step = ""; // what it is doing now; empty when idle
    this.focused = "issue";
    this.fields = {};
    this.values = { issue: "", what: "" };
    const field = (name, placeholder) => {
      const input = InputState.new({ value: "", placeholder });
      input.on("change", (_e, cx) => { this.values[name] = input.value(); this.error = ""; cx.notify(); });
      input.on("submit", (_e, cx) => this.go(cx));
      input.on("focus", (_e, cx) => { this.focused = name; cx.notify(); });
      this.fields[name] = input;
    };
    field("issue", "number or URL; blank for work without one");
    field("what", "what you want to do");
    this.handle = cx.focus_handle();
    this.fields.issue.focus();
    cx.timer.after(150, () => this.fields[this.focused].focus());
    // Where the person is now decides the repo; read it before the dialog takes focus.
    this.from = panes().find((p) => p.focused)?.cwd ?? null;
  }

  go(cx) {
    if (this.step) return;
    cx.spawn(async (cx) => {
      const say = (step) => { this.step = step; cx.notify(); };
      try {
        this.error = await this.work(cx, say);
      } catch (error) { this.error = String(error?.message ?? error); }
      this.step = "";
      if (!this.error) closeOverlay(props().overlay);
      cx.notify();
    });
  }

  async work(cx, say) {
    const issueText = this.values.issue.trim();
    const what = this.values.what.trim();
    const number = issueText ? issueNumber(issueText) : null;
    if (issueText && !number) return "That should be a number, or a GitHub issue or pull request URL.";
    if (!number && !what) return "Give an issue or pull request, a description, or both.";

    say("finding the repository…");
    const repo = (await mainCheckout(this.from)) ?? (await mainCheckout(`${home()}/${FALLBACK_REPO}`));
    if (!repo) return `Not in a git repository, and ~/${FALLBACK_REPO} isn't one either.`;

    // pull: the pull request whose branch this work is on; null for a new branch.
    let branch, task, pull = null;
    if (number) {
      say(`reading #${number}…`);
      // The issues endpoint answers for pull requests too, and says which it is.
      const r = await exec("gh", ["api", `repos/{owner}/{repo}/issues/${number}`], { cwd: repo });
      if (r.code !== 0) return (r.stderr || `Couldn't read #${number}.`).trim();
      const issue = JSON.parse(r.stdout);
      let read;
      if (issue.pull_request) {
        const p = await exec("gh", ["pr", "view", number, "--json", "headRefName,isCrossRepository"], { cwd: repo });
        if (p.code !== 0) return (p.stderr || `Couldn't read pull request #${number}.`).trim();
        pull = JSON.parse(p.stdout);
        if (pull.isCrossRepository) return `Pull request #${number} comes from a fork; its branch isn't on origin.`;
        branch = pull.headRefName;
        read = `We're working on pull request #${issue.number}: "${issue.title}", on its branch \`${branch}\`. Read it with \`gh pr view ${issue.number} --comments\` and \`gh pr diff ${issue.number}\`.`;
      } else {
        branch = kebab(`${issue.number}-${issue.title}`);
        read = `We're working on GitHub issue #${issue.number}: "${issue.title}". Read it with \`gh issue view ${issue.number} --comments\`.`;
      }
      task = what ? `${read}\n\nWhat I want: ${what}` : `${read} Tell me how you understand it, and wait for me before changing anything.`;
    } else {
      branch = kebab(what);
      task = what;
    }
    if (!branch) return "That doesn't make a branch name. Use some letters or digits.";

    // A pull request's branch may have slashes; the folder gets dashes, as Herdr's own worktrees do.
    let path = `${await worktreeRoot()}/${repo.split("/").at(-1)}/${branch.replace(/\//g, "-")}`;
    const listed = (await git(repo, ["worktree", "list", "--porcelain"])).out.split("\n\n").map((entry) => entry.split("\n"));
    const inMain = listed.some((lines) => lines[0] === `worktree ${repo}` && lines.includes(`branch refs/heads/${branch}`));
    if (inMain) {
      // The main checkout is already on this branch: git won't check it out twice, so work there.
      path = repo;
    } else if (!listed.some((lines) => lines[0] === `worktree ${path}`)) {
      const exists = (await git(repo, ["show-ref", "--verify", "--quiet", `refs/heads/${branch}`])).ok;
      let add = ["worktree", "add", path, branch];
      if (pull) {
        say("fetching the pull request's branch…");
        const fetched = await git(repo, ["fetch", "origin", branch], 120_000);
        if (!fetched.ok) return fetched.err || "git fetch failed.";
        // A local branch that already exists is used as it is, not moved to the remote's.
        if (!exists) add = ["worktree", "add", "--track", "-b", branch, path, `origin/${branch}`];
      } else if (!exists) {
        say("fetching the default branch…");
        const head = await git(repo, ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"]);
        const base = head.ok ? head.out : "origin/master";
        const fetched = await git(repo, ["fetch", "origin", base.replace(/^origin\//, "")], 120_000);
        if (!fetched.ok) return fetched.err || "git fetch failed.";
        // --no-track: the new branch must not push to the default branch.
        add = ["worktree", "add", "--no-track", "-b", branch, path, base];
      }
      say("creating the worktree…");
      const added = await git(repo, add, 600_000);
      if (!added.ok) return added.err || "git worktree add failed.";
    }

    say("opening the space…");
    const before = new Set(spaces().map((s) => s.id));
    // Unnamed, so the sidebar names it after its branch and nests it under the repo.
    run("space.new", { folder: path, argv: AGENT, task });
    let space;
    for (let i = 0; i < 100 && !space; i++) {
      space = spaces().find((s) => !before.has(s.id));
      if (!space) await cx.sleep(50);
    }
    if (!space) return "";
    const tabs = new Set(space.tabs.map((t) => t.id));
    const agent = panes().find((p) => tabs.has(p.tab));
    run("terminal.open", { folder: path, place: "right" });
    if (agent) run("pane.focus", { pane: agent.pane });
    return "";
  }

  key(e, cx) {
    if (e.key === "escape") { closeOverlay(props().overlay); cx.stop_propagation(); }
    if (e.key === "tab") {
      this.focused = this.focused === "issue" ? "what" : "issue";
      this.fields[this.focused].focus();
      cx.stop_propagation();
      cx.notify();
    }
  }

  render() {
    const t = theme();
    const issueText = this.values.issue.trim(), what = this.values.what.trim();
    const number = issueText ? issueNumber(issueText) : null;
    const preview = issueText && !number ? "" : number ? `Branch: ${number}-<issue title>, or the pull request's own` : what ? `Branch: ${kebab(what)}` : "";
    const label = (text) => div().text_size(11.5).text_color(t.dim).child(text);
    const input = (name) => Input.new(this.fields[name]).h(36).px(10).items_center().rounded(8).border(1)
      .border_color(this.focused === name ? t.accent : t.input).bg(t.background).text_color(t.foreground);
    return v_flex().id("start-work").track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .size_full().p(18).gap(8).bg(t.popover).text_size(13).text_color(t.foreground)
      .child(h_flex().items_center()
        .child(div().flex_1().text_size(15).font_semibold().child("Start work"))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(div().pb(4).text_color(t.muted).child("A worktree in its own space, with Claude and a shell: off the default branch, or on a pull request's branch."))
      .child(label("Issue or pull request"))
      .child(input("issue"))
      .child(div().pt(4).child(label("Description")))
      .child(input("what"))
      .when(Boolean(preview) && !this.error, (el) => el.child(div().text_size(11.5).text_color(t.dim).truncate().child(preview)))
      .when(Boolean(this.error), (el) => el.child(div().text_color(t.blocked).child(this.error)))
      .child(div().flex_1())
      .child(h_flex().justify_end().gap(6).text_size(11).text_color(t.dim)
        .when(Boolean(this.step), (el) => el.child(div().frames(["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"], 90)))
        .child(this.step || "tab next field · ↵ start · esc cancel"));
  }
}
