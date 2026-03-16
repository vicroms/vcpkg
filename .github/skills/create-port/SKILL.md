---
name: create-port
description: 'Create new vcpkg ports from scratch. Use for adding new packages, creating port structure, setting up CMake integration, managing dependencies, and ensuring vcpkg compliance.'
argument-hint: 'GitHub URL (e.g., "https://github.com/owner/repo")'
---

# New Port Creator

## When to Use

- Adding a new open-source library to the vcpkg registry
- Creating port structure with proper manifest and build files
- Setting up CMake integration for packages
- Ensuring compliance with vcpkg packaging standards
- Converting existing libraries to vcpkg ports


## Overview

This skill guides you through creating a complete vcpkg port from a GitHub repository URL, including:
- Automatic port name and homepage extraction from GitHub URL
- Repository analysis and build system detection  
- `vcpkg.json` manifest generation
- `portfile.cmake` build script creation with proper GitHub integration
- CMake usage documentation
- Version database initialization
- License and copyright handling
- Validating port conforms with the vcpkg maintainer guide: https://learn.microsoft.com/vcpkg/contributing/maintainer-guide

**Streamlined Process:** Simply provide a GitHub URL and the skill handles the rest!

## Interactive Creation Process

### Step 1: GitHub Repository Input

The skill will prompt for:

**Primary Input:**
- **GitHub Repository URL**: The main source repository (e.g., `https://github.com/fmtlib/fmt`)

**Auto-extracted from GitHub URL:**
- **Package name**: Derived from repository name with vcpkg naming conventions applied
- **Homepage**: The GitHub repository URL
- **Repository info**: Owner/repo for `vcpkg_from_github()` calls

**Additional Required Information:**
- **Version**: Current upstream version (e.g., `1.2.3`, `2023-04-15`) 
- **Description**: One-line summary of what the package does
- **License**: SPDX license identifier (e.g., `MIT`, `Apache-2.0`, `GPL-3.0`)

**Optional Information:**
- **Dependencies**: Other vcpkg packages this port depends on
- **Features**: Optional components that can be enabled/disabled
- **Build system**: CMake, autotools, MSBuild, custom, etc.
- **Custom port name**: Override auto-generated name if needed

### Step 2: Auto-extraction and Validation

The skill will:
- **Extract repository details** from the GitHub URL (owner, repo name, default branch)
- **Analyze release tags** to determine appropriate version scheme:
  - **With releases**: Use latest release tag (e.g., `v1.2.3` → `"version": "1.2.3"`)
  - **No releases**: Use `version-date` scheme with latest commit date (e.g., `"version-date": "2024-03-16"`)
- **Generate port name** following vcpkg maintainer guide conventions:
  - Lowercase with hyphens: `MyAwesomeLib` → `myawesomelib`
  - Remove common prefixes: `libfoo` → `foo`, `OpenSSL` → `openssl`
  - Handle ambiguous names: Add GitHub owner prefix if needed (`owner-repo`)
- **Validate repository accessibility** and check for common files (README, LICENSE, etc.)
- **Check for existing ports** with the same or similar names in vcpkg registry
- **Cross-reference with repology.org** to validate name usage across package managers
- **Perform web search validation** to confirm name-to-project association strength
- **Suggest naming alternatives** if conflicts exist, names are ambiguous, or lack strong association

**Port Name Generation Algorithm:**
1. Start with repository name
2. Convert to lowercase
3. Replace underscores with hyphens: `my_library` → `my-library`  
4. Remove common prefixes/suffixes: `lib`, `cpp`, `open`, numerals
5. **Check repology.org** for existing package usage across package managers
6. **Validate name recognition** through web search engines
7. **Check for ambiguity** against existing ports and general usage
8. **Apply naming decision** based on validation results:
   - If name is well-established across package managers → use simple name
   - If web search shows library as top result → use simple name  
   - If name conflicts or lacks strong association → use `owner-repo` pattern
9. Allow manual override if auto-generated name isn't suitable

**Name Validation Process:**
- **Repology Check**: Query https://repology.org to see if proposed name is used by other package managers (apt, homebrew, conda, etc.) for the same project
- **Web Search Validation**: Search engines (with "c++ library" term) should show the target project as primary result
- **Cross-Reference Analysis**: Compare GitHub repository, repology entries, and search results for consistency
- **Disambiguation Strategy**: Use `owner-repo` format when name association is weak or ambiguous

### Step 3: Repository Analysis

The skill automatically analyzes the GitHub repository to:
- **Detect version scheme**: 
  - **Check release tags**: Look for semantic versions (`v1.2.3`), date tags (`2024-03-16`), or custom patterns
  - **Latest commit analysis**: If no releases, get latest commit date for `version-date` scheme
  - **Version pattern recognition**: Identify upstream versioning convention (semver, dates, etc.)
- **Detect build system and recommend vcpkg helper**: 
  - **CMake** (`CMakeLists.txt`) → Use `vcpkg_cmake_configure()` and `vcpkg_cmake_install()`
  - **Meson** (`meson.build`) → Add `vcpkg-meson` dependency, use `vcpkg_configure_meson()`
  - **Make** (`Makefile`, `GNUmakefile`) → Add `vcpkg-make` dependency, use `vcpkg_configure_make()`
  - **Autotools** (`configure.ac`, `configure.in`) → Use `vcpkg_configure_autotools()`
  - **MSBuild** (`*.sln`, `*.vcxproj`) → Add `vcpkg-msbuild` dependency, use `vcpkg_install_msbuild()`
  - **GN** (`BUILD.gn`) → Add `vcpkg-gn` dependency, use `vcpkg_gn_configure()`
  - **Premake** (`premake5.lua`) → Create custom `CMakeLists.txt` (unsupported build system)
- **Identify library type**: Header-only (no source files) vs compiled library
- **Find license file**: Scan for `LICENSE`, `COPYING`, `MIT.txt`, etc. and identify SPDX license
- **Extract description**: Use repository description or README title
- **Detect dependencies**: Analyze `CMakeLists.txt`, `package.json`, etc.
- **Determine head branch**: `main`, `master`, `develop`, etc.

**Smart Version Handling:**
- **Releases found**: Use latest release with appropriate scheme (`version`, `version-semver`)
- **No releases**: Use `version-date` with latest commit date
- **Custom patterns**: Handle non-standard versioning (date-based, custom formats)
- **Version validation**: Ensure compliance with vcpkg versioning requirements

**Smart Defaults:**
- **Recommends appropriate vcpkg helper** based on detected build system (CMake, Meson, Make, etc.)
- **Adds required dependencies** automatically (e.g., `vcpkg-meson` for Meson projects)
- **Validates port names** using repology.org and web search to ensure appropriate naming decisions
- **Suggests vcpkg_check_linkage(ONLY_STATIC_LIBRARY)** on Windows for libraries with DLL export issues
- **Pre-fills common configuration options** for detected frameworks
- Identifies popular packages (Boost, Qt, etc.) for special handling

### Step 4: Port Structure Generation

Creates the following directory structure:
```
ports/{package-name}/
├── vcpkg.json              # Package manifest with auto-detected info
├── portfile.cmake          # Build instructions optimized for the repository
├── usage                   # CMake integration guide with correct targets
├── CMakeLists.txt          # Build configuration (only for unsupported build systems)
└── xConfig.cmake.in        # CMake config template (if creating custom CMake files)
```

**Key Dependencies Added:**
- `vcpkg-cmake` (host dependency) - Provides modern CMake functions
- `vcpkg-cmake-config` (host dependency) - Provides CMake config fixup functions
- **Build system specific dependencies** (e.g., `vcpkg-meson`, `vcpkg-make`) when using supported build systems

**Template Customization:**

Each file is generated with repository-specific optimizations:

**vcpkg.json**: Package metadata with vcpkg-cmake dependencies
```json
{
  "name": "package-name",
  "version-date": "2024-03-16",
  "description": "Package description",
  "homepage": "https://github.com/owner/repo",
  "license": "MIT",
  "dependencies": [
    {
      "name": "vcpkg-cmake",
      "host": true
    },
    {
      "name": "vcpkg-cmake-config",
      "host": true
    }
  ]
}
```

**portfile.cmake**: Build script using appropriate build system helpers
```cmake
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owner/repo
    REF commit-hash
    SHA512 0  # Set to 0 first, then use calculated value
    HEAD_REF main
)

# Handle DLL export issues on Windows if needed
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# For CMake projects (most common)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

# For Meson projects
# vcpkg_configure_meson(
#     SOURCE_PATH "${SOURCE_PATH}"
# )

# For Make projects  
# vcpkg_configure_make(
#     SOURCE_PATH "${SOURCE_PATH}"
# )

# For custom build systems only
# file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
# file(COPY "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_install()

# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_cmake_config_fixup(
    PACKAGE_NAME package-name
    CONFIG_PATH lib/cmake/package-name
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
```

**usage**: Minimal CMake integration with unofficial namespace
```cmake
package-name provides CMake targets:

  find_package(package-name CONFIG REQUIRED)
  target_link_libraries(main PRIVATE unofficial::package-name)
```

### Step 5: GitHub Integration Examples

**Input:** `https://github.com/fmtlib/fmt`
**Analysis Results:**
- Port name: `fmt` (simple, non-ambiguous name)
- Version: `10.2.1` (latest release tag `10.2.1`)
- Scheme: `"version": "10.2.1"`
- Homepage: `https://github.com/fmtlib/fmt`
- Repository: `fmtlib/fmt`
- Portfile uses: `vcpkg_from_github(... REPO fmtlib/fmt REF "10.2.1" ...)`

**Input:** `https://github.com/nlohmann/json`
**Analysis Results:**
- Port name: `nlohmann-json` (GitHub owner prefix to avoid ambiguous "json")
- Version: `3.11.3` (latest release tag `v3.11.3`)
- Scheme: `"version": "3.11.3"`
- Homepage: `https://github.com/nlohmann/json`
- Repository: `nlohmann/json`
- CMake target: `unofficial::nlohmann-json`

**Input:** `https://github.com/gabime/spdlog`
**Analysis Results:**
- Port name: `spdlog` (distinctive name, no conflicts)
- Version: `1.12.0` (latest release tag `v1.12.0`)
- Scheme: `"version": "1.12.0"`
- Auto-detects: Header-only vs compiled library
- Build system: CMake detected

**Input:** `https://github.com/someuser/experimental-lib` (no releases)
**Analysis Results:**
- Port name: `someuser-experimental-lib` (prefix added for distinctiveness)
- Version: `2024-03-16` (latest commit date)
- Scheme: `"version-date": "2024-03-16"`
- HEAD_REF: `main`

### Step 6: Post-Creation Checklist

The skill provides:
- [ ] Test the port builds successfully: `vcpkg install {package-name}`
- [ ] Verify all triplets work: `vcpkg install {package-name}:x64-windows`
- [ ] Check static/shared library outputs
- [ ] Validate license file installation
- [ ] Test CMake integration with usage examples
- [ ] Update version database: `vcpkg x-add-version {package-name}`
- [ ] Run CI validation: `vcpkg ci {package-name}`

## Example Workflow

**Simple 3-step process:**

1. **Input GitHub URL**: `/create-port https://github.com/gabime/spdlog`

2. **Review auto-detected info**:
   - Port name: `spdlog` (distinctive, no conflicts found)
   - Version: `1.12.0` (detected from latest release tag `v1.12.0`)
   - Version scheme: `"version": "1.12.0"` (follows upstream semantic versioning)
   - Build system: CMake (detected from `CMakeLists.txt`)
   - License: MIT (found `LICENSE` file)
   - Description: "Fast C++ logging library" (from repo description)

3. **Confirm and create**: Complete port structure generated instantly!

**Alternative example (no releases):**

1. **Input**: `/create-port https://github.com/owner/new-project`
2. **Auto-detected**:
   - Port name: `owner-new-project` (prefix added for distinctiveness)
   - Version: `2024-03-16` (latest commit date, no releases found)
   - Version scheme: `"version-date": "2024-03-16"` (vcpkg convention for unreleased projects)
   - Build system: Custom Makefile (no CMake detected)

**Result:** Ready-to-test port with proper GitHub integration and CMake targets.

## Common Port Patterns

### CMake-based Libraries
Most modern C++ libraries use CMake. The generated portfile will use:
- `vcpkg_from_github()` for GitHub-hosted projects
- `vcpkg_cmake_configure()` for CMake configuration (requires vcpkg-cmake dependency)
- `vcpkg_cmake_install()` for installation (requires vcpkg-cmake dependency)
- `vcpkg_cmake_config_fixup()` for CMake target fixes (requires vcpkg-cmake-config dependency)

**Required Dependencies in vcpkg.json:**
```json
"dependencies": [
  {
    "name": "vcpkg-cmake",
    "host": true
  },
  {
    "name": "vcpkg-cmake-config", 
    "host": true
  }
]
```

### Supported Build Systems
For projects using build systems that vcpkg supports natively:
- **CMake projects**: Use `vcpkg_cmake_configure()` and `vcpkg_cmake_install()` directly
- **Meson projects**: Add `vcpkg-meson` dependency and use `vcpkg_configure_meson()` and `vcpkg_install_meson()`
- **Make projects**: Add `vcpkg-make` dependency and use `vcpkg_configure_make()` and `vcpkg_install_make()`
- **MSBuild projects**: Add `vcpkg-msbuild` dependency and use `vcpkg_install_msbuild()`
- **GN projects**: Add `vcpkg-gn` dependency and use `vcpkg_gn_configure()` and `vcpkg_gn_install()`
- **Autotools projects**: Use `vcpkg_configure_autotools()` and `vcpkg_install_autotools()`

### Custom Build Systems (Last Resort)
Only create custom `CMakeLists.txt` files when the upstream build system is not supported by vcpkg:
- **Premake projects** (like xatlas)
- **Custom build scripts** that don't fit standard patterns
- **Header-only libraries** that need CMake target generation

**When creating custom CMakeLists.txt:**
- Create separate file in port directory: `CMakeLists.txt`
- Copy to source before configuration: `file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")`
- Use `unofficial::` namespace for all generated CMake targets
- Handle DLL export issues with `vcpkg_check_linkage(ONLY_STATIC_LIBRARY)` in portfile instead of forcing static in CMakeLists.txt

### Header-Only Libraries  
For header-only libraries, the portfile focuses on:
- File installation without compilation
- CMake target creation for easy consumption
- Proper include directory setup

### Complex Build Systems
For projects with custom build systems:
- `vcpkg_download_distfile()` for source archives
- `vcpkg_execute_build_process()` for custom build commands
- Manual file installation and CMake target creation

### Tool Dependencies
When a port requires external tools for building (code generators, build tools, etc.), handle them properly using vcpkg's tool acquisition mechanisms.

**Tool Dependency Resolution Strategy:**

1. **Use `vcpkg_find_acquire_program()` first** for common build tools:
   ```cmake
   # For standard tools available through vcpkg_find_acquire_program
   vcpkg_find_acquire_program(FLEX)
   vcpkg_find_acquire_program(BISON)
   vcpkg_find_acquire_program(PYTHON3)
   vcpkg_find_acquire_program(PERL)
   vcpkg_find_acquire_program(PKGCONFIG)
   vcpkg_find_acquire_program(NASM)
   vcpkg_find_acquire_program(YASM)
   vcpkg_find_acquire_program(DOXYGEN)
   ```

2. **Search for vcpkg tool ports** if not available through `vcpkg_find_acquire_program`:
   ```bash
   vcpkg search <tool-name>
   # Look for ports with [tool] designation
   ```

3. **Add tool ports as dependencies** when available:
   ```json
   {
     "dependencies": [
       {
         "name": "tool-port-name", 
         "host": true
       }
     ]
   }
   ```

**Common Tool Dependency Patterns:**

**Flex and Bison (Parser Generators):**
```cmake
# Use vcpkg_find_acquire_program for standard parser tools
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

# Configure build to use acquired tools
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLEX_EXECUTABLE=${FLEX}
        -DBISON_EXECUTABLE=${BISON}
)
```

**Python for Build Scripts:**
```cmake
# Acquire Python for build-time scripts
vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPYTHON_EXECUTABLE=${PYTHON3}
)
```

**Documentation Generation:**
```cmake
# For projects that optionally build documentation
vcpkg_find_acquire_program(DOXYGEN)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDOXYGEN_EXECUTABLE=${DOXYGEN}
        -DBUILD_DOCS=OFF  # Usually disable docs in vcpkg ports
)
```

**Tool Ports as Dependencies:**
```json
{
  "name": "example-port",
  "dependencies": [
    {
      "name": "protobuf",
      "host": true
    },
    {
      "name": "grpc",
      "host": true  
    }
  ]
}
```

**Available Tool Programs via vcpkg_find_acquire_program:**
- **PYTHON3/PYTHON2**: Python interpreters
- **PERL**: Perl interpreter  
- **RUBY**: Ruby interpreter
- **JOM**: Parallel make tool for MSVC
- **NINJA**: Ninja build system
- **NUGET**: .NET package manager
- **GIT**: Git version control
- **FLEX**: Lexical analyzer generator
- **BISON**: Parser generator
- **GPERF**: Perfect hash function generator
- **NASM/YASM**: x86/x64 assemblers
- **DOXYGEN**: Documentation generator
- **PKGCONFIG**: Library metadata tool
- **SWIG**: Interface wrapper generator

**Tool Port Examples:**
- **protobuf[tools]**: Protocol buffer compiler (`protoc`)
- **grpc[tools]**: gRPC plugin for protoc
- **qt5-tools**: Qt development tools (moc, uic, rcc)
- **cmake[tools]**: CMake build system (usually not needed as host dependency)
- **pkgconf[tools]**: Modern pkg-config implementation

**Best Practices for Tool Dependencies:**

1. **Prefer vcpkg_find_acquire_program** for standard tools when available
2. **Use host dependencies** for tool ports: `"host": true` in dependencies
3. **Disable optional tool usage** when not essential (documentation, examples)
4. **Validate tool availability** in portfile before usage:
   ```cmake
   if(TOOL_FOUND)
       # Use the tool
   else()
       message(STATUS "Tool not found, skipping optional feature")
   endif()
   ```

5. **Pass tool paths explicitly** to build systems rather than relying on PATH:
   ```cmake
   vcpkg_cmake_configure(
       SOURCE_PATH "${SOURCE_PATH}"
       OPTIONS
           -DPROTOC_EXECUTABLE=${PROTOBUF_PROTOC_EXECUTABLE}
   )
   ```

**Tool Dependency Examples:**

**Project requiring Protocol Buffers:**
```cmake
# First check for vcpkg tool port
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DProtobuf_PROTOC_EXECUTABLE=${PROTOBUF_PROTOC_EXECUTABLE}
)
```

```json
{
  "dependencies": [
    "protobuf",
    {
      "name": "protobuf",
      "host": true,
      "features": ["tools"]
    }
  ]
}
```

**Project requiring custom code generator:**
```cmake
# If tool not available via vcpkg_find_acquire_program, use tool port
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"  
    OPTIONS
        -DCUSTOM_GENERATOR=${CURRENT_HOST_INSTALLED_DIR}/tools/custom-generator/generator${VCPKG_HOST_EXECUTABLE_SUFFIX}
)
```

```json
{
  "dependencies": [
    {
      "name": "custom-generator-tool",
      "host": true
    }
  ]
}
```

## Patch Management

When source code modifications are required to make a library work with vcpkg, use the `PATCHES` parameter with `vcpkg_from_github()` instead of modifying source code directly in the portfile.

### Patch Requirements
Patches must be implemented using the `PATCHES` parameter on `vcpkg_from_github`. This parameter accepts diff or patch files that can be applied using the `git apply` command.

### Generating Patches

To generate patches for a port:

1. **Create a local clone** of the original source code repository:
   ```bash
   git clone https://github.com/owner/repo.git
   cd repo
   git checkout <commit-hash>  # Use the same commit as in your port
   ```

2. **Make necessary changes** to the source code:
   - Fix build issues for vcpkg compatibility
   - Add missing CMake exports
   - Correct header installations
   - Fix dependency detection

3. **Create patch files** containing the changes:
   ```bash
   git add .
   git commit -m "Fix for vcpkg compatibility"
   git format-patch HEAD~1 --output-directory ../patches
   ```
   
   Alternatively, create patches manually:
   ```bash
   git diff > ../patches/001-fix-build.patch
   ```

4. **Place patch files** in your port's directory:
   ```
   ports/package-name/
   ├── vcpkg.json
   ├── portfile.cmake
   ├── usage
   └── patches/
       ├── 001-fix-cmake-exports.patch
       └── 002-fix-installation-paths.patch
   ```

5. **Apply patches in portfile** using the `PATCHES` parameter:

```cmake
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owner/repo
    REF "v1.2.3"
    SHA512 abc123...
    HEAD_REF main
    PATCHES
        patches/001-fix-cmake-exports.patch
        patches/002-fix-installation-paths.patch
)
```

### Patch Best Practices

**Patch Organization:**
- Use descriptive filenames: `001-fix-cmake-exports.patch`, `002-add-missing-headers.patch`
- Number patches if order matters: `001-`, `002-`, etc.
- Keep patches focused on single issues when possible

**Patch Content Guidelines:**
- **Minimal changes**: Only modify what's necessary for vcpkg compatibility
- **Clear commit messages**: Explain why each change is needed
- **Test compatibility**: Ensure patches work across different platforms
- **Version independence**: Write patches that work across minor version updates when possible

**Common Patch Scenarios:**
- **CMake fixes**: Export missing targets, fix installation paths
- **Build system issues**: Add missing compiler flags or dependencies
- **Include path corrections**: Fix header installations or missing includes
- **Platform compatibility**: Add Windows/macOS/Linux specific fixes
- **Dependency detection**: Fix find_package() calls or pkg-config usage

### Example Patch Usage

**Simple patch example:**
```cmake
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF "v1.12.0" 
    SHA512 abc123...
    HEAD_REF v1.x
    PATCHES
        patches/001-fix-cmake-config.patch
)
```

**Multiple patches example:**
```cmake
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owner/complex-lib
    REF "v2.1.0"
    SHA512 def456...
    HEAD_REF master
    PATCHES
        patches/001-fix-cmake-exports.patch
        patches/002-add-windows-support.patch
        patches/003-fix-dependency-detection.patch
)
```

### Maintaining Patches
- **Version updates**: Review and update patches when upgrading library versions
- **Upstream contributions**: Consider submitting patches upstream to reduce maintenance
- **Documentation**: Comment patch purposes in the portfile when not obvious
- **Testing**: Verify patches apply cleanly after library updates

## Libraries Not Suitable for vcpkg

Some libraries are fundamentally incompatible with vcpkg's packaging model and should not be ported. Recognizing these early saves development effort.

### Licensing Incompatibilities  
Libraries with licenses incompatible with vcpkg's distribution model:

**Examples:**
- Commercial licenses requiring end-user agreements
- Restrictive licenses prohibiting redistribution
- Patents or proprietary components

**Note:** Most open source licenses (GPL, LGPL, MIT, Apache) are suitable with proper attribution.

### Pre-Analysis Checklist
Before creating a port, verify:
- [ ] Library builds from source without external binary dependencies
- [ ] All dependencies are available through vcpkg or system packages
- [ ] License permits redistribution
- [ ] No embedded platform-specific binaries required
- [ ] No system service or driver dependencies
- [ ] Build system produces standard libraries/headers (not just tools/utilities)

### Alternative Approaches
For unsuitable libraries, consider:
- **System Installation**: Document manual installation in README
- **Tool Dependencies**: Reference as external tools rather than vcpkg ports
- **Wrapper Libraries**: Create abstraction layer that works with vcpkg-compatible alternatives
- **Documentation**: Provide integration guides for system-installed versions

## Templates Reference

Use these template files as starting points:

- **[CMake Library Template](./templates/cmake-library.vcpkg.json)**: Standard CMake-based library
- **[Header-Only Template](./templates/header-only.vcpkg.json)**: Header-only libraries  
- **[Complex Build Template](./templates/complex-build.portfile.cmake)**: Custom build systems

## Best Practices

### Dependency Management
Ports in vcpkg should remove any vendored dependencies and instead acquire them from vcpkg. This ensures consistency, security updates, and reduces duplication across the ecosystem.

**Vendored Dependency Identification:**
During repository analysis, identify vendored dependencies by looking for:
- Third-party libraries embedded in `vendor/`, `third-party/`, `deps/`, `external/` directories
- Git submodules pointing to external libraries
- Header files from other projects included directly in the source tree
- Static libraries (`*.lib`, `*.a`) bundled with the source code

**Dependency Replacement Process:**

1. **Identify all vendored dependencies**:
   ```bash
   # Common vendored dependency locations
   vendor/
   third-party/
   deps/
   external/
   lib/
   include/third-party/
   ```

2. **Check vcpkg availability**:
   ```bash
   vcpkg search <dependency-name>
   ```

3. **Add existing vcpkg dependencies to manifest**:
   ```json
   {
     "dependencies": [
       "existing-vcpkg-library",
       "another-dependency-from-vcpkg"
     ]
   }
   ```

4. **Create new ports for missing dependencies**:
   - For dependencies not available in vcpkg, create separate ports first
   - Follow the same port creation process for each vendored library

5. **Remove vendored code from source**:
   Use patches to remove vendored dependencies and update build system:
   ```cmake
   # In patches/001-remove-vendored-deps.patch:
   # Remove vendor directory references
   # Update CMakeLists.txt to use find_package() instead
   # Remove embedded source compilation
   ```

6. **Update build configuration**:
   Patch the build system to use vcpkg dependencies:
   ```cmake
   # Replace vendored usage:
   # add_subdirectory(vendor/somelib)
   
   # With vcpkg dependency:
   # find_package(somelib CONFIG REQUIRED)
   # target_link_libraries(main PRIVATE somelib::somelib)
   ```

**Example Vendored Dependency Removal:**

**Before (with vendored dependencies):**
```cmake
# Original CMakeLists.txt includes vendored libs
add_subdirectory(vendor/fmt)
add_subdirectory(vendor/spdlog)
add_subdirectory(third-party/json)

target_link_libraries(mylib PRIVATE fmt spdlog nlohmann_json)
```

**After (using vcpkg dependencies):**
```json
// vcpkg.json
{
  "dependencies": [
    "fmt",
    "spdlog", 
    "nlohmann-json"
  ]
}
```

```cmake
# Patched CMakeLists.txt uses vcpkg packages
find_package(fmt CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)

target_link_libraries(mylib PRIVATE 
    fmt::fmt 
    spdlog::spdlog 
    nlohmann_json::nlohmann_json
)
```

**Patches for Vendored Removal:**
Create patches that:
- Remove vendored directory references from build files
- Replace `add_subdirectory()` calls with `find_package()` calls
- Update target link libraries to use proper CMake targets
- Remove any vendored source file compilations

**Common Vendored Dependencies:**
- **JSON libraries**: nlohmann/json, rapidjson, jsoncpp
- **Logging libraries**: spdlog, fmt
- **HTTP clients**: curl, cpr, httplib
- **Testing frameworks**: googletest, catch2
- **Cryptography**: openssl, mbedtls
- **Compression**: zlib, bzip2, lz4

**Missing Dependency Strategy:**
When a vendored dependency doesn't exist in vcpkg:
1. **Check if it's suitable for vcpkg** (open source, builds from source, etc.)
2. **Create the dependency port first** before creating the main port
3. **Submit dependency ports separately** to get them merged first
4. **Use proper version constraints** to ensure compatibility

**Benefits of Removing Vendored Dependencies:**
- **Security**: Automatic updates when vulnerabilities are fixed
- **Consistency**: Same library versions across all ports
- **Maintenance**: Reduced port complexity and update burden
- **Disk space**: Avoid duplicate libraries across ports
- **Build time**: Reuse compiled dependencies across projects

### Intelligent Port Naming
The skill follows vcpkg maintainer guidelines for distinctive port names:

**Naming Rules (from vcpkg maintainer guide):**
- **Distinctive names**: Port name should be indicative of contents and findable in search engines
- **Avoid ambiguous names**: Short names or common words require disambiguation
- **Remove common affixes**: Strip `lib`, `cpp`, `free`, `open`, numerals when checking ambiguity
- **GitHub prefix**: Use `<owner>-<repo>` format for ambiguous names or unclear projects
- **Preserve uniqueness**: Ensure no conflicts with existing vcpkg ports

**Examples of Good Naming:**
- `https://github.com/fmtlib/fmt` → `fmt` (distinctive, well-known across all package managers)
- `https://github.com/google/leveldb` → `leveldb` (recognized name in repology.org and web search)
- `https://github.com/nlohmann/json` → `nlohmann-json` (avoids ambiguous "json", follows owner-repo pattern)
- `https://github.com/microsoft/cpprestsdk` → `cpprestsdk` (established name, strong search results)

**Name Validation Examples:**

**Case 1: Well-established name**
- Repository: `https://github.com/fmtlib/fmt`
- Repology check: "fmt" used consistently across apt, homebrew, conda for same library
- Web search: "fmt c++ library" → top result is fmtlib/fmt
- **Decision**: Use `fmt` (simple name)

**Case 2: Ambiguous generic name**
- Repository: `https://github.com/someuser/http`
- Repology check: "http" used by multiple unrelated projects
- Web search: "http c++ library" → mixed results, no clear association
- **Decision**: Use `someuser-http` (owner-repo pattern)

**Case 3: Clear association**
- Repository: `https://github.com/gabime/spdlog` 
- Repology check: "spdlog" consistently refers to this logging library
- Web search: "spdlog c++ library" → primary result is gabime/spdlog
- **Decision**: Use `spdlog` (simple name)

**Auto-disambiguation:**
- `json` → `nlohmann-json` (generic term, multiple competing libraries)
- `http` → `owner-http` (common word, no strong association)
- `utils` → `owner-utils` (too vague, fails specificity test)
- `fmt` → `fmt` (strong cross-platform recognition, passes validation)

### Smart Version Detection
The skill automatically determines the best version scheme:

**Version Scheme Priority:**
1. **Semantic releases** (`v1.2.3`) → `"version": "1.2.3"`
2. **Date-based releases** (`2024-03-16`) → `"version-date": "2024-03-16"`  
3. **Custom releases** → `"version-string": "custom-version"`
4. **No releases** → `"version-date": "YYYY-MM-DD"` (latest commit date)

**Follows vcpkg guidelines:**
- Respects upstream versioning conventions
- Uses appropriate vcpkg version schemes
- Handles unreleased projects correctly with version-date

### Manifest (vcpkg.json)
- Use semantic versioning when upstream provides it
- Include comprehensive description from repository
- Specify exact dependency requirements
- Add features for optional components
- Use proper SPDX license identifiers

### Portfile (portfile.cmake)
- **Use appropriate vcpkg build system helpers** (vcpkg-cmake, vcpkg-meson, vcpkg-make, etc.)
- **Add required build system dependencies** (e.g., vcpkg-meson for Meson projects)
- **Use vcpkg_check_linkage(ONLY_STATIC_LIBRARY)** for Windows DLL export issues instead of forcing static in build files
- **Create separate CMakeLists.txt files only for unsupported build systems** (Premake, custom scripts)
- **Set SHA512 to 0 initially**, then use the calculated hash from first build attempt
- **Install usage file properly**: `file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")`
- Install license files with `vcpkg_install_copyright()`
- Remove debug headers/docs: `file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")`
- Clean up empty directories to avoid post-build warnings

### CMake Integration
- Provide both `find_package()` and direct target syntax
- Use `unofficial::` namespace for all vcpkg-created targets (required by vcpkg guidelines)
- Include both required and optional component examples
- Follow modern CMake patterns for compatibility

## Validation Commands

After port creation, run these commands to validate:

```powershell
# Test basic installation (will calculate SHA512 if set to 0)
vcpkg install {package-name}

# If SHA512 was 0, update portfile.cmake with the calculated hash and reinstall
# (vcpkg will provide the correct hash in the error message)

# Test different triplets
vcpkg install {package-name}:x64-windows
vcpkg install {package-name}:x64-linux  
vcpkg install {package-name}:x64-osx

# Validate version database
vcpkg x-add-version {package-name}
vcpkg x-ci-verify-versions

# Run CI tests
vcpkg ci {package-name}
```

**SHA512 Hash Workflow:**
1. Set `SHA512 0` in portfile.cmake initially  
2. Run `vcpkg install {package-name}`
3. Copy the calculated SHA512 from the error message
4. Update portfile.cmake with the correct SHA512
5. Run `vcpkg install {package-name}` again to complete the build

### Post-Build Validation

A successful port build should show:
- ✅ No post-build warnings
- ✅ Usage file properly installed  
- ✅ CMake targets use unofficial:: namespace
- ✅ License file correctly installed
- ✅ Clean directory structure (no empty folders)

## Troubleshooting

### Common Issues

**Build Failures:**
- Verify source URL and SHA512 hash (set to 0 first for auto-calculation)
- Check CMake configuration options
- Ensure vcpkg-cmake dependencies are properly specified
- Use correct GitHub commit hash (not shortened version)

**CMake Function Not Found:**
```
Unknown CMake command "vcpkg_cmake_configure"
```
- **Solution**: Add vcpkg-cmake and vcpkg-cmake-config host dependencies to vcpkg.json

**DLL Export Issues:**
```
DLLs were built without any exports
```
- **Solution**: Use `vcpkg_check_linkage(ONLY_STATIC_LIBRARY)` in portfile.cmake
- Add at the beginning of portfile for Windows-only static linking:
```cmake
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
```
- **Alternative**: If library supports proper DLL exports, ensure `__declspec(dllimport)` and `__declspec(dllexport)` are correctly used
- **Avoid**: Don't force static builds in CMakeLists.txt unless absolutely necessary

**Usage File Not Installed:**
```
this port contains a file named "usage" but didn't install it
```
- **Solution**: Add `file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")`

**CMake Target Issues:**
- Run `vcpkg_cmake_config_fixup()` to fix target imports
- Ensure unofficial:: namespace is used for all vcpkg-generated targets
- Validate usage file examples work correctly

**License Problems:**  
- Ensure license file exists in source
- Use `vcpkg_install_copyright()` with correct file path
- Verify SPDX license identifier is accurate

## Next Steps

After successful port creation:
1. **Test thoroughly** across all supported platforms
2. **Submit PR** to microsoft/vcpkg repository
3. **Update documentation** if the package requires special setup
4. **Monitor CI** for any platform-specific issues
5. **Respond to reviews** and iterate on feedback

## Reference Documentation

- [vcpkg Portfile Functions](./references/portfile-functions.md)
- [CMake Integration Patterns](./references/cmake-patterns.md)
- [Platform-Specific Considerations](./references/platform-notes.md)
- [Dependency Management Guide](./references/dependencies.md)