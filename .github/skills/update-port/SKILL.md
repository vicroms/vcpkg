---
name: update-port
description: 'Update an existing vcpkg port of a library to the latest upstream version. Update portfiles, patches, and manifest as needed. Also repair any downstream ports that may get broken by the update.'
argument-hint: 'Port name (e.g. "allegro5")'
---

# vcpkg Port Update Skill

## When to use

- Updating an existing vcpkg port to a new upstream version
- Fixing a build failure in an existing port
- Enabling new features for an existing port
- Modernizing an existing port to use vcpkg's latest best practices

## Overview

This skill guides you through the process of updating an existing vcpkg port. This may be necessary when a new upstream version is released, when a build failure is reported, or when you want to enable new features. The skill covers how to update the portfiles, patches, and manifest as needed, as well as how to identify and repair any downstream ports that may get broken by the update.

- **Find upstream version:** Check the library's official website, GitHub releases, or package repository to find the latest stable version.
- **Update portfiles:** Modify the `vcpkg.json` and `portfile.cmake` files to reflect the new version, including updating source URLs, checksums, and any build instructions.
- **Update patches:** If there are existing patches, check if they still apply to the new version. If not, update or remove them as necessary.
- **Test build:** Build the updated port locally to ensure it compiles successfully and passes any tests.
- **Check downstream ports:** Identify any ports that depend on the updated port and test them to ensure they are not broken by the update. If they are, update their portfiles and patches as needed.
