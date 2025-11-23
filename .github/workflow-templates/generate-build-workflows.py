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
    Generate a per-distro workflow YAML for a given distro using the template.
    """
    name_short = distro["name"].lower().replace(" ", "-")
    workflow_content = template_content

    # Replace placeholders
    workflow_content = workflow_content.replace("{{NAME}}", distro["name"])
    workflow_content = workflow_content.replace("{{NAME_SHORT}}", name_short)
    workflow_content = workflow_content.replace("{{DOCKER_TAG}}", distro.get("docker_tag", ""))
    workflow_content = workflow_content.replace("{{BUILD_DIR_PREFIX}}", distro.get("build_dir_prefix", ""))
    workflow_content = workflow_content.replace("{{TAG_PREFIX}}", tag_prefix_template.replace("{{NAME_SHORT}}", name_short))
    workflow_content = workflow_content.replace("{{FULLNAME}}", distro["fullname"])

    # Output filename matches tag prefix for clarity
    output_file = os.path.join(output_dir, f"{tag_prefix_template.replace('{{NAME_SHORT}}', name_short)}.yml")
    with open(output_file, "w") as f:
        f.write(workflow_content)

    return output_file

def generate_matrix_workflow(template_content: str, output_file: str, distros: list, tag_prefix: str) -> str:
    """
    Generate a matrix workflow YAML that includes all distros in one workflow.
    """
    workflow_content = template_content

    # Insert the JSON array of distros for the matrix
    distros_json = json.dumps(distros, indent=2)
    workflow_content = workflow_content.replace("{{DISTROS_JSON}}", distros_json)
    workflow_content = workflow_content.replace("{{TAG_PREFIX}}", tag_prefix)
    workflow_content = workflow_content.replace("{{NAME_SHORT}}", "all")

    output_path = os.path.join(OUTPUT_DIR, output_file)
    with open(output_path, "w") as f:
        f.write(workflow_content)

    return output_path

def main():
    # Load distros
    with open(DISTROS_FILE, "r") as f:
        distros = json.load(f)

    # Generate per-distro workflows
    for template_file, tag_prefix_template in TEMPLATE_TAG_PREFIX.items():
        template_path = os.path.join(TEMPLATES_DIR, template_file)
        with open(template_path, "r") as f:
            template_content = f.read()

        for distro in distros:
            # For docker-builds, only generate per-distro; no matrix
            if "docker" in template_file:
                output_file = generate_workflow(template_content, distro, OUTPUT_DIR, tag_prefix_template)
                print(f"Generated workflow: {output_file}")
            else:
                # per-distro workflows
                output_file = generate_workflow(template_content, distro, OUTPUT_DIR, tag_prefix_template)
                print(f"Generated workflow: {output_file}")

        # Generate matrix workflow only for builds.yml and builds-with-zimbra.yml
        if template_file in ["builds.yml", "builds-with-zimbra.yml"]:
            matrix_tag_prefix = "builds" if template_file == "builds.yml" else "builds-with-zimbra"
            matrix_output_file = template_file  # same filename for matrix workflow
            output_file = generate_matrix_workflow(template_content, matrix_output_file, distros, matrix_tag_prefix)
            print(f"Generated matrix workflow: {output_file}")

if __name__ == "__main__":
    main()
