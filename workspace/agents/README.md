# Sub-Agents

This folder is where you add specialized agents under your main one.

## How to Add a Sub-Agent

1. Create a new folder here with your agent's ID:
   ```
   agents/my-sub-agent/
   ```

2. Add three files:

   **`IDENTITY.md`** — The agent's ID card:
   ```yaml
   agentId: my-sub-agent
   name: My Sub-Agent
   emoji: 🔧
   color: "#E74C3C"
   description: What this sub-agent does.
   ```

   **`SOUL.md`** — The agent's personality.

   **`AGENTS.md`** — The agent's instructions and capabilities.

3. Reference this sub-agent in your main `workspace/AGENTS.md` under the Subordinates section.

4. Your main agent can now communicate with it:
   ```
   sessions_send --to my-sub-agent --message "Do the thing"
   ```

## Examples of Sub-Agents

- **Research Agent** — finds and summarises information
- **Social Agent** — handles social media engagement
- **Support Agent** — answers customer questions
- **Finance Agent** — tracks budgets and transactions

Start with your main agent. Add sub-agents when you actually need them.
