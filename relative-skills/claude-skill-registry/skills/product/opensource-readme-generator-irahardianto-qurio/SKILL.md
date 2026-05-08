---
name: opensource-readme-generator
description: Generate high-quality, "All-Star" README files for open-source repositories. Use this skill when a user asks to create, update, or improve a README.md file for their project.
license: MIT
---

# Open Source README Generator

This skill helps you generate professional, comprehensive, and visually appealing README files for open-source projects.

## Usage Guidelines

When a user asks to create or improve a README:

1.  **Analyze the Project:**
    *   Look at the files in the current directory (using `ls -R` or similar tools if allowed/safe) to understand the project type (Node.js, Python, Go, etc.).
    *   Identify key components: `package.json`, `requirements.txt`, source code folders, tests.
    *   Determine the project name and purpose.

2.  **Gather Information:**
    *   If the project purpose isn't clear from the code, ask the user for a brief description, "elevator pitch", or key features.
    *   Ask about specific sections if they are missing (e.g., "Do you have a demo link?", "What is the license?").

3.  **Use the Template:**
    *   Read the template at `assets/all-star-readme-template.md`.
    *   Use this template as the structure for your output.
    *   **Do not** just copy the template blindly. Fill in the placeholders (`github_username`, `repo_name`, etc.) with real data from the project or reasonable placeholders if unknown.
    *   Customize the badges in the "Built With" section to match the technologies actually used in the project.

4.  **Consult Guidelines:**
    *   Refer to `references/readme-guidelines.md` to ensure you are meeting the "All-Star" criteria (clarity, visuals, completeness).

## Workflow

1.  **Understand:** Read the user's request and explore the codebase to understand what the project does.
2.  **Draft:** Create a draft of the `README.md` in your mind or a scratchpad, mapping project details to the template sections.
3.  **Refine:** Check against `references/readme-guidelines.md`.
4.  **Output:** Write the content to `README.md` (or a file specified by the user) using the `write_file` tool.

## Tips

*   **Badges:** Always include badges. They make the repo look active and professional.
*   **Visuals:** If you can't generate a screenshot, add a placeholder like `![Screenshot](path/to/screenshot.png)` and tell the user to replace it.
*   **Tone:** Keep the tone professional, welcoming, and helpful.