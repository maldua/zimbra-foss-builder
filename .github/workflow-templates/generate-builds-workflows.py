#!/usr/bin/env python3
import json
import os

# Paths
TEMPLATES_DIR = os.path.dirname(__file__)
DISTROS_FILE = os.path.join(TEMPLATES_DIR, "distros.json")
OUTPUT_DIR = os.path.join(TEMPLATES_DIR, "../workflows")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Map template filename → tag prefix pattern
TEMPLATE_TAG_PREFIX = {
    "builds.yml": "builds-{{NAME_SHORT}}",
    "builds-with-zimbra.yml": "builds-with-pimbra-{{NAME_SHORT}}",
    "docker-builds.yml": "docker-builds-{{NAME_SHORT}}"
}

def generate_workflow(template_content: str, distro: dict, output_dir: str, tag_prefix_template: str) -> str:
    """
    Generate a workflow YAML for a given distro using the template.
    The tag prefix can be template-specific.
    """
    name_short = distro["name"].lower().replace(" ", "-")
    workflow_content = template_content

    # Replace placeholders
    workflow_content = workflow_content.replace("{{NAME}}", distro["name"])
    workflow_content = workflow_content.replace("{{NAME_SHORT}}", name_short)
    workflow_content = workflow_content.replace("{{DOCKER_TAG}}", distro["docker_tag"])
    workflow_content = workflow_content.replace("{{BUILD_DIR_PREFIX}}", distro["build_dir_prefix"])
    workflow_content = workflow_content.replace("{{TAG_PREFIX}}", tag_prefix_template.replace("{{NAME_SHORT}}", name_short))
    workflow_content = workflow_content.replace("{{FULLNAME}}", distro["fullname"])

    # Output filename matches tag prefix for clarity
    output_file = os.path.join(output_dir, f"{tag_prefix_template.replace('{{NAME_SHORT}}', name_short)}.yml")
    with open(output_file, "w") as f:
        f.write(workflow_content)

    return output_file

def main():
    # Load distros
    with open(DISTROS_FILE, "r") as f:
        distros = json.load(f)

    # Generate workflows for each template
    for template_file, tag_prefix_template in TEMPLATE_TAG_PREFIX.items():
        template_path = os.path.join(TEMPLATES_DIR, template_file)
        with open(template_path, "r") as f:
            template_content = f.read()

        for distro in distros:
            output_file = generate_workflow(template_content, distro, OUTPUT_DIR, tag_prefix_template)
            print(f"Generated workflow: {output_file}")

if __name__ == "__main__":
    main()
