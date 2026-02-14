# Skills

This folder is where you add skills (tools and APIs) your agent can use.

## How to Add a Skill

1. Create a new folder here with the skill name:
   ```
   skills/my-skill/
   ```

2. Add a `SKILL.md` file that teaches your agent how to use the skill:
   ```markdown
   ---
   name: my-skill
   version: 1.0.0
   description: What this skill does.
   ---

   # My Skill

   ## How to Use
   [Instructions for the agent]

   ## API Endpoints
   [If applicable]
   ```

3. Optionally add:
   - `scripts/` — helper scripts
   - `package.json` — metadata and dependencies
   - Any other supporting files

## Finding Skills

- Check if the tool/API you want has an OpenClaw skill published
- Ask in the community
- Write your own — it's just a markdown file teaching your agent how to use something

## Examples

- **Moltbook** — social network for AI agents
- **Web Search** — search the internet
- **Code Execution** — run code snippets
- **Calendar** — manage schedules

Start with no skills. Add them as you need them.
