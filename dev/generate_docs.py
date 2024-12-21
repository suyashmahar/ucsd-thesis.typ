#!/usr/bin/env python3

import re

def parse_typst_states_and_args(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    print("Parsing file:", file_path)

    # Regex for matching state variables along with the preceding comment:
    #  - Captures a comment line (`// ...`) right before a `#let name = state("...", ...)` pattern.
    #  - The group references are:
    #     (1) the comment text after `// `
    #     (2) the state name in the file (e.g. "otln_new_chp_spc")
    #     (3) the default value (e.g. 1em, etc.)
    state_pattern = re.compile(
        r'//\s*(.*?)\s*\n#let\s+[\w_]+\s*=\s*state\("([^"]+)"\s*,\s*(.*?)\)',
        re.DOTALL
    )

    # Regex for matching arguments of the `ucsd_thesis` function:
    #  - Captures a comment line right before a line like: `arg: "default",`
    #  - The group references are:
    #     (1) the comment text
    #     (2) the argument name (e.g. subject)
    #     (3) the default value (e.g. "Computer Science", none, etc.)
    # This assumes each argument is on its own line, with one comment line above.
    args_pattern = re.compile(
        r'//\s*(.*?)\s*\n\s*([\w_]+)\s*:\s*(.*?)(?=,\s*\n|\),)',
        re.DOTALL
    )

    states_info = state_pattern.findall(content)
    args_info = []

    # We only want to look inside the parentheses of `#let ucsd_thesis(...) = { ... }`.
    # A quick approach is to isolate the portion between `#let ucsd_thesis(` and `) = {`.
    thesis_function_pattern = re.compile(
        r'#let\s+ucsd_thesis\s*\(\s*(.*?)\s*\)\s*=\s*{', re.DOTALL
    )
    thesis_function_match = thesis_function_pattern.search(content)
    if thesis_function_match:
        thesis_args_content = thesis_function_match.group(1)
        args_info = args_pattern.findall(thesis_args_content)

    # Format the extracted data in Markdown:
    markdown_lines = []
    
    markdown_lines.append("## Arguments\n")
    for comment, arg_name, default_value in args_info:
        markdown_lines.append(f"### `{arg_name}`")
        markdown_lines.append(comment.strip().replace("// ", ""))
        markdown_lines.append("\n")
        markdown_lines.append(f"*Default Value:* `{default_value.strip()}`\n")

    markdown_lines.append("\n")

    markdown_lines.append("## State Variables\n")
    for comment, state_name, default_value in states_info:
        markdown_lines.append(f"### `{state_name}`")
        markdown_lines.append(comment.strip().replace("// ", ""))
        markdown_lines.append("\n")
        markdown_lines.append(f"*Default Value:* `{default_value.strip()}`\n")

    return "\n".join(markdown_lines)


if __name__ == "__main__":
    markdown_output = parse_typst_states_and_args("ucsd_thesis.typ")
    print(markdown_output)
