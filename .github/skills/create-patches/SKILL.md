---
name: create-patches
description: 'Create and manage patches for vcpkg ports. Use for fixing build issues, adding compatibility modifications, and managing source code changes required for vcpkg integration.'
argument-hint: 'Port name, or: --build-dir <path-to-buildtrees/port> --port-dir <path-to-ports/port> for analyzing build failures'
---

# vcpkg Patch Creator

## When to Use

- **Fixing build failures**: Analyze build errors from failed vcpkg installations and create patches
- **Build system incompatibilities**: Fix build issues for vcpkg compatibility
- **Adding missing CMake exports**: Export targets for proper vcpkg integration
- **Platform-specific fixes**: Add Windows/macOS/Linux compatibility modifications
- **Dependency management**: Replace vendored dependencies with vcpkg packages
- **Installation corrections**: Fix header paths, library installation, and file organization
- **Existing port maintenance**: Update patches for version upgrades or new issues

## Independent Usage Modes

### Mode 1: Build Failure Analysis (Recommended)
Use when vcpkg install fails and you need to analyze and fix build issues:

**Arguments:**
- `--build-dir <path>`: Path to failed build directory (e.g., `buildtrees/package-name/`)
- `--port-dir <path>`: Path to corresponding port directory (e.g., `ports/package-name/`)

**Example:**
```
create-patches --build-dir buildtrees/mylibrary --port-dir ports/mylibrary
```

This mode will:
- Analyze build logs for common failure patterns
- Examine the extracted source code for issues
- Identify missing CMake exports, build system problems, or platform issues
- Guide you through creating appropriate patches

### Mode 2: Port Name (Simple)
Use for general patch creation when you know the port name. This mode deducts the build and port directories based on the provided port name:
```
create-patches mylibrary
```

## Overview

This skill guides you through creating and managing patches for vcpkg ports when source code modifications are required to make a library work with vcpkg. Patches are the proper way to handle source modifications rather than editing code directly in the portfile.

**Two Primary Workflows:**
1. **Build Failure Analysis**: Analyze failed vcpkg builds and create patches to fix issues
2. **Proactive Patch Creation**: Create patches for new ports or planned modifications

## Build Failure Analysis Workflow

### Step 1: Identify Build Failure

When `vcpkg install package-name` fails, the skill can analyze the failure:

**Build Directory Structure:**
```
buildtrees/package-name/
├── src/                    # Extracted source code
│   └── commit-hash/        # Source at specific commit
├── build-triplet/          # Build attempt outputs
│   ├── CMakeCache.txt      # CMake configuration
│   ├── config.log          # Build system logs  
│   └── *.log              # Detailed build logs
└── vcpkg-*.log            # vcpkg-specific logs
```

**Port Directory Structure:**
```
ports/package-name/
├── vcpkg.json             # Current manifest
├── portfile.cmake         # Current build script
├── usage                  # Usage documentation
└── patches/               # Existing patches (if any)
```

### Step 2: Analyze Build Logs

The skill examines build logs to identify common failure patterns:

**CMake Configuration Failures:**
- Missing dependencies: `Could not find package XYZ`
- Export target issues: `Target "name" was not found`
- Installation path problems: `Cannot find include directory`

**Compilation Failures:**
- Missing headers: `fatal error: 'header.h' file not found`
- Windows DLL export issues: `unresolved external symbol`
- Platform-specific compiler errors

**Link-time Failures:**
- Missing libraries: `cannot find -llibname`
- Symbol resolution issues: `undefined reference to`

**Installation Failures:**
- File not found during install: `Cannot install non-existent target`
- Permission or path issues during file operations

### Step 3: Source Code Analysis

The skill examines the extracted source code to understand:

**Build System Detection:**
- CMake: Analyze `CMakeLists.txt` for export issues
- Makefiles: Check installation targets and paths
- Custom build systems: Identify integration requirements

**Common Issues Identification:**
- Missing CMake target exports
- Incorrect installation paths
- Vendored dependencies that need replacement
- Platform-specific compatibility problems
- Missing DLL export declarations

### Step 4: Guided Patch Creation

Based on the analysis, the skill provides specific patch recommendations:

**Automatic Issue Detection:**
```
Analyzing build failure in: buildtrees/mylibrary/x64-windows/
Port directory: ports/mylibrary/

ISSUES FOUND:
❌ CMake Error: Target "mylibrary" not exported in CMakeLists.txt
❌ Windows: Missing DLL export macros in public headers  
❌ Installation: Headers not installed to correct path

RECOMMENDED PATCHES:
📋 001-add-cmake-exports.patch - Add CMake target exports
📋 002-fix-dll-exports.patch - Add Windows DLL export macros
📋 003-fix-header-installation.patch - Correct header install paths
```

**Interactive Patch Generation:**
- Shows exact code changes needed
- Generates patch files automatically
- Provides testing instructions
- Updates portfile.cmake with PATCHES parameter

## Patch Requirements

Patches must be implemented using the `PATCHES` parameter with `vcpkg_from_github()`. This parameter accepts diff or patch files that can be applied using the `git apply` command.

**Key Rules:**
- **Use PATCHES parameter only** - Never modify source code directly in portfile.cmake
- **Minimal changes** - Only modify what's necessary for vcpkg compatibility
- **Test across platforms** - Ensure patches work on Windows, macOS, and Linux
- **Version independence** - Write patches that work across minor version updates when possible

## Using Build Failure Analysis

### Prerequisites

1. **Failed vcpkg installation** that needs fixing
2. **Build directory** preserved (in `buildtrees/package-name/`)
3. **Port directory** with current portfile (in `ports/package-name/`)

### Step-by-Step Process

**1. Locate Build Artifacts:**
```bash
# After failed vcpkg install, locate build directory
ls buildtrees/package-name/
# Should show: src/, x64-windows/, arm64-windows/, etc.

# Confirm port directory exists
ls ports/package-name/ 
# Should show: vcpkg.json, portfile.cmake, usage
```

**2. Run Build Analysis:**
```
create-patches --build-dir buildtrees/mylibrary --port-dir ports/mylibrary
```

**3. Review Analysis Results:**
The skill will examine:
- **Build logs**: Parse error messages and failure points
- **Source code**: Analyze build system and structure
- **Current portfile**: Check for missing configurations
- **Existing patches**: Review what's already applied

**4. Follow Guided Recommendations:**
Based on analysis, receive specific guidance such as:
- Exact CMake code to add for exports
- DLL export macro additions for Windows
- Header installation path corrections
- Dependency replacement instructions

**5. Generate and Apply Patches:**
The skill automates:
- Creating properly formatted patch files
- Placing them in the correct directory structure
- Updating portfile.cmake with PATCHES parameter
- Providing testing instructions

### Example Analysis Session

**Input:**
```bash
create-patches --build-dir buildtrees/rapidjson --port-dir ports/rapidjson
```

**Analysis Output:**
```
🔍 Analyzing build failure...

BUILD DIRECTORY: buildtrees/rapidjson/
- Source extracted to: buildtrees/rapidjson/src/v1.1.0-973dc9a06d/
- Build attempted in: buildtrees/rapidjson/x64-windows/
- Log files found: CMakeCache.txt, config-*.log

PORT DIRECTORY: ports/rapidjson/
- Manifest: vcpkg.json ✓
- Portfile: portfile.cmake ✓ 
- Usage: usage ✓

🔴 ISSUES IDENTIFIED:

1. CMake Export Missing:
   Location: buildtrees/rapidjson/src/v1.1.0-973dc9a06d/CMakeLists.txt
   Issue: No install(EXPORT) commands found
   Error: "RapidJSON::RapidJSON target not found"

2. Header Installation Path:
   Location: CMakeLists.txt line 45
   Issue: Headers installed to wrong path
   Error: "Could not find include/rapidjson"

📋 PATCH RECOMMENDATIONS:

Creating: patches/001-add-cmake-exports.patch
- Add install(EXPORT RapidJSONTargets ...)
- Export RapidJSON::RapidJSON target
- Place config in lib/cmake/RapidJSON

Creating: patches/002-fix-header-paths.patch  
- Correct include directory installation
- Ensure headers go to include/rapidjson/

⚙️ NEXT STEPS:
1. Apply patches to portfile.cmake
2. Test with: vcpkg install rapidjson --debug
3. Verify CMake integration works
```

## Manual Patch Creation Workflow

## Manual Patch Creation Workflow

When working without build failure analysis or creating patches proactively:

### Using Build Directory Sources (After Failed Build)

If you have a failed build available, you can work directly with the extracted source:

**1. Locate extracted source:**
```bash
# Find the extracted source in buildtrees
cd buildtrees/package-name/src/commit-hash/
# This is the exact source code that failed to build
```

**2. Make changes directly to extracted source:**
```bash
# Edit the source files to fix issues
# Example: Add CMake exports, fix includes, etc.
```

**3. Generate patches from modified source:**
```bash
# From within the source directory
git init
git add .
git commit -m "Original source"

# Make your modifications, then:
git add .
git commit -m "Fix for vcpkg compatibility"
git format-patch HEAD~1 --output-directory ../../../ports/package-name/patches/
```

### Using Fresh Clone (Traditional Method)

### Step 1: Create Local Clone

Create a local clone of the original source code repository:
```bash
git clone https://github.com/owner/repo.git
cd repo
git checkout <commit-hash>  # Use the same commit as in your port
```

Use the exact same commit hash that your portfile.cmake references in the `REF` parameter.

### Step 2: Make Necessary Changes

Make the required changes to fix vcpkg compatibility issues:

**Common Patch Scenarios:**
- **CMake fixes**: Export missing targets, fix installation paths
- **Build system issues**: Add missing compiler flags or dependencies  
- **Include path corrections**: Fix header installations or missing includes
- **Platform compatibility**: Add Windows/macOS/Linux specific fixes
- **Dependency detection**: Fix find_package() calls or pkg-config usage
- **Remove vendored dependencies**: Replace embedded libraries with vcpkg dependencies

**Example Changes:**
```cmake
# Fix CMake exports
install(TARGETS mylib EXPORT mylibTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib  
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(EXPORT mylibTargets
    FILE mylibConfig.cmake
    NAMESPACE mylib::
    DESTINATION lib/cmake/mylib
)
```

### Step 3: Create Patch Files

Generate patch files containing your changes:

**Method 1: Using git format-patch (Recommended)**
```bash
git add .
git commit -m "Fix for vcpkg compatibility"
git format-patch HEAD~1 --output-directory ../patches
```

**Method 2: Using git diff**
```bash
git diff > ../patches/001-fix-build.patch
```

**Method 3: Multiple commits**
```bash
# For multiple logical changes
git add file1.cmake
git commit -m "Fix CMake exports"
git add file2.cpp  
git commit -m "Add Windows compatibility"

# Generate separate patches
git format-patch HEAD~2 --output-directory ../patches
```

### Step 4: Organize Patch Files

Place patch files in your port's directory with descriptive names:
```
ports/package-name/
├── vcpkg.json
├── portfile.cmake
├── usage
└── patches/
    ├── 001-fix-cmake-exports.patch
    ├── 002-fix-installation-paths.patch
    └── 003-add-windows-support.patch
```

**Patch Naming Convention:**
- Use descriptive filenames: `001-fix-cmake-exports.patch`, `002-add-missing-headers.patch`
- Number patches if order matters: `001-`, `002-`, `003-`, etc.
- Keep patches focused on single logical issues when possible

### Step 5: Apply Patches in Portfile

Apply patches in portfile.cmake using the `PATCHES` parameter:

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
        patches/003-add-windows-support.patch
)
```

**Important Notes:**
- List patches in the order they should be applied
- Use relative paths from the port directory
- Patches are applied automatically before build configuration

## Patch Best Practices

### Content Guidelines

**Focus on vcpkg Compatibility:**
- Only modify what's necessary for vcpkg integration
- Avoid cosmetic changes or code style modifications
- Fix specific build failures or missing functionality
- Don't include debugging code or temporary workarounds

**Clear Documentation:**
- Use descriptive commit messages explaining why each change is needed
- Add comments in complex patches explaining the fix
- Document any assumptions or platform-specific considerations

**Maintain Compatibility:**
- Test patches on Windows, macOS, and Linux if the library supports them
- Verify patches work with both Debug and Release configurations
- Check that patches don't break existing functionality

### Common Patch Patterns

**1. CMake Export Fixes:**
```cmake
# Add missing CMake exports
install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Config.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION lib/cmake/${PROJECT_NAME}
)
```

**2. Include Path Corrections:**
```cmake
# Fix header installation
install(DIRECTORY include/ 
    DESTINATION include/${PROJECT_NAME}
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)
```

**3. Platform-Specific Fixes:**
```cpp
// Add Windows compatibility
#ifdef _WIN32
    #ifdef BUILDING_DLL
        #define API_EXPORT __declspec(dllexport)
    #else
        #define API_EXPORT __declspec(dllimport)
    #endif
#else
    #define API_EXPORT
#endif
```

**4. Dependency Detection Fixes:**
```cmake
# Replace custom find modules with find_package
find_package(OpenSSL REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE OpenSSL::SSL OpenSSL::Crypto)
```

**5. Remove Vendored Dependencies:**
```cmake
# Remove vendored library usage
# BEFORE:
# add_subdirectory(vendor/json)
# target_link_libraries(mylib PRIVATE nlohmann_json)

# AFTER (with patch):
find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(mylib PRIVATE nlohmann_json::nlohmann_json)
```

### Testing Patches

**Local Testing:**
```bash
# Test patch application
cd source-directory
git apply ../ports/package-name/patches/001-fix-build.patch

# Verify no conflicts
echo $?  # Should be 0 for success
```

**vcpkg Testing:**
```bash
# Test full port build with patches
vcpkg install package-name

# Test on different triplets
vcpkg install package-name:x64-windows
vcpkg install package-name:x64-linux
```

## Example Workflows

### Scenario 1: Fixing Failed vcpkg Install

**Problem:** `vcpkg install mypackage` fails with CMake export errors.

**Using Build Analysis Approach:**

1. **Run analysis:**
   ```bash
   create-patches --build-dir buildtrees/mypackage --port-dir ports/mypackage
   ```

2. **Review analysis results:**
   ```
   🔴 CMake Error: Target "mypackage::mypackage" not found
   📁 Source location: buildtrees/mypackage/src/v1.2.3-abc123/
   📋 Creating patch: patches/001-add-cmake-exports.patch
   ```

3. **Apply auto-generated patch:**
   - Patch files created automatically in `ports/mypackage/patches/`
   - Portfile.cmake updated with PATCHES parameter
   - Ready to test with `vcpkg install mypackage`

**Using Manual Approach:**

1. **Work with extracted source:**
   ```bash
   cd buildtrees/mypackage/src/v1.2.3-abc123/
   git init && git add . && git commit -m "Original source"
   ```

2. **Add missing CMake exports:**
   ```cmake
   # Edit CMakeLists.txt
   install(TARGETS mypackage
       EXPORT mypackageTargets
       LIBRARY DESTINATION lib
       ARCHIVE DESTINATION lib
       RUNTIME DESTINATION bin
       INCLUDES DESTINATION include
   )
   
   install(EXPORT mypackageTargets
       FILE mypackageConfig.cmake
       NAMESPACE mypackage::
       DESTINATION lib/cmake/mypackage
   )
   ```

3. **Generate and apply patch:**
   ```bash
   git add . && git commit -m "Add CMake exports"
   git format-patch HEAD~1 --output-directory=../../../../ports/mypackage/patches/
   ```

### Scenario 2: Missing CMake Exports

**Using Build Analysis:**
- Analysis detects: "No install(EXPORT) commands in CMakeLists.txt"
- Auto-generates patch with proper CMake export syntax
- Updates portfile.cmake automatically

**Manual Alternative:**
- Clone repository and add exports manually
- Follow traditional patch generation process

### Scenario 3: Windows DLL Export Issues

**Problem:** `vcpkg install mylib:x64-windows` fails with DLL export errors.

**Using Build Analysis Approach:**

1. **Run analysis after failed build:**
   ```bash
   create-patches --build-dir buildtrees/mylib --port-dir ports/mylib
   ```

2. **Analysis identifies Windows-specific issue:**
   ```
   🔴 Windows Build Error: "dllexport/dllimport not declared"
   📁 Headers needing exports: include/mylib/api.h, include/mylib/core.h
   📋 Creating patch: patches/001-add-dll-exports.patch
   ```

3. **Auto-generated patch includes:**
   - DLL export macro definitions
   - Applied to all public API functions
   - Platform-conditional compilation

**Manual Approach:**

1. **Work with failed build source:**
   ```bash
   cd buildtrees/mylib/src/commit-hash/
   # The extracted source that actually failed
   ```

2. **Add export macros:**
   ```cpp
   // Add to config.h or main header
   #ifdef _WIN32
       #ifdef BUILDING_MYLIB
           #define MYLIB_API __declspec(dllexport)
       #else  
           #define MYLIB_API __declspec(dllimport)
       #endif
   #else
       #define MYLIB_API
   #endif
   
   // Apply to public functions
   MYLIB_API void public_function();
   ```

### Scenario 4: Remove Vendored Dependencies

**Problem:** Library includes vendored dependencies that should use vcpkg packages.

**Using Build Analysis:**
- Detects embedded libraries in vendor/ or third-party/ directories
- Identifies which dependencies are available in vcpkg
- Generates patches to remove vendored code and update build system
- Updates vcpkg.json with required dependencies

**Manual Approach:**
- Analyze library structure manually
- Remove vendored directories
- Update build system to use find_package()
- Create dependency manifest entries

## Advantages of Build Directory Analysis

**Working with Actual Failed Source:**
- Uses the exact source code that failed to build
- No need to match commit hashes or versions
- Patches apply to the precise state vcpkg attempted to build

**Automated Issue Detection:**
- Parses actual build logs for specific error patterns
- Identifies root causes rather than symptoms
- Suggests appropriate fixes based on error analysis

**Contextual Patches:**
- Patches created knowing the exact build environment
- Takes into account existing portfile configuration
- Considers any existing patches already applied

**Faster Iteration:**
- No need to clone repositories or match versions
- Work directly with failed build artifacts
- Test patches immediately with existing vcpkg setup

## When to Use Each Approach

**Use Build Analysis When:**
- vcpkg install has already failed
- You have access to buildtrees/ and ports/ directories
- Want automated issue detection and patch generation
- Need to fix existing port maintenance issues

**Use Manual Clone Approach When:**
- Creating patches for new ports before any vcpkg build
- Working on upstream contributions
- Need to understand broader source code context
- Creating comprehensive patches across multiple commits

## Maintaining Patches

### Version Updates

When updating library versions:

1. **Test patch application:**
   ```bash
   git clone https://github.com/owner/repo.git
   cd repo
   git checkout new-version
   git apply ../ports/package-name/patches/*.patch
   ```

2. **Update patches if needed:**
   - Resolve any conflicts manually
   - Regenerate patches with updated line numbers
   - Test that fixes are still necessary

3. **Consider upstream contributions:**
   - Submit patches upstream to reduce maintenance burden
   - Reference upstream PR/issue in patch comments
   - Remove patches when fixes are included upstream

### Documentation

**In portfile.cmake comments:**
```cmake
# Apply patches for vcpkg compatibility:
# - 001-fix-cmake-exports.patch: Add missing CMake target exports
# - 002-windows-dll-fix.patch: Fix Windows DLL symbol exports  
# - 003-remove-vendored-deps.patch: Use vcpkg dependencies instead of embedded libraries
PATCHES
    patches/001-fix-cmake-exports.patch
    patches/002-windows-dll-fix.patch  
    patches/003-remove-vendored-deps.patch
```

**In patch commit messages:**
```
Fix CMake target exports for vcpkg compatibility

- Add install(EXPORT) commands for mylibTargets
- Export targets to lib/cmake/mylib/mylibConfig.cmake
- Use mylib:: namespace for exported targets
- Required for proper vcpkg CMake integration
```

## Validation and Testing

### Testing Patches from Build Analysis

After creating patches using build failure analysis:

1. **Test immediate patch application:**
   ```bash
   # Patches should be auto-applied to portfile.cmake
   # Test the fixed build
   vcpkg install package-name --debug
   ```

2. **Verify build success:**
   ```bash
   # Check that build completes without errors
   # Verify all originally failing steps now pass
   ```

3. **Test integration:**
   ```cmake
   # Create test CMakeLists.txt
   find_package(package-name CONFIG REQUIRED)
   target_link_libraries(test PRIVATE package-name::package-name)
   ```

### Build Directory Analysis Advantages

**Immediate Context:**
- Works with the exact source code that failed
- No version matching needed - uses buildtrees/ content  
- Sees the actual build environment and configuration used

**Automated Problem Detection:**
- Parses real build logs for specific error patterns
- Identifies missing CMake exports, DLL issues, path problems
- Suggests specific solutions based on actual failures

**Streamlined Workflow:**
- No need to clone repositories separately
- Patches generated in correct directory structure
- Portfile.cmake updated automatically

**Common Use Cases:**
```bash
# When builds fail with missing CMake targets
create-patches --build-dir buildtrees/failing-lib --port-dir ports/failing-lib

# When Windows DLL export errors occur  
create-patches --build-dir buildtrees/windows-lib --port-dir ports/windows-lib

# When header installation fails
create-patches --build-dir buildtrees/header-lib --port-dir ports/header-lib
```

### Traditional Clone Method Advantages

**Comprehensive Source Access:**
- Full repository history and context
- Access to documentation, examples, tests
- Ability to understand broader architectural decisions

**Upstream Contribution Prep:**
- Patches suitable for submitting upstream
- Clean commit history for pull requests  
- Better for creating comprehensive fixes

### Testing Manually Created Patches

For traditional manually created patches:

1. **Verify patch application:**
   ```bash
   # Test on clean source
   vcpkg install package-name --debug
   # Check build logs for successful patch application
   ```

2. **Cross-platform testing:**
   ```bash
   # Test all supported platforms
   vcpkg install package-name:x64-windows
   vcpkg install package-name:x64-linux  
   vcpkg install package-name:x64-osx
   ```

3. **Configuration testing:**
   ```bash
   # Test both debug and release
   vcpkg install package-name --debug
   ```

4. **Integration testing:**
   Create a test project using the patched library:
   ```cmake
   find_package(mypackage CONFIG REQUIRED)
   target_link_libraries(test PRIVATE mypackage::mypackage)
   ```

### Common Issues and Solutions

**Patch Application Fails:**
```
error: patch does not apply
```
- **Cause**: Line numbers changed in source code
- **Solution**: Regenerate patch against current version

**Build Still Fails After Patch:**
```
error: target 'mylib::mylib' was not found
```
- **Cause**: Patch incomplete or CMake target name mismatch
- **Solution**: Verify CMake export syntax and target names

**Runtime Issues:**
```
error: cannot find DLL exports
```
- **Cause**: Missing DLL export macros or definitions
- **Solution**: Add proper `__declspec(dllexport/dllimport)` declarations

## Best Practices Summary

1. **Minimal changes**: Only patch what's necessary for vcpkg compatibility
2. **Clear documentation**: Explain why each patch is needed
3. **Test thoroughly**: Verify patches work across platforms and configurations
4. **Organize properly**: Use numbered, descriptive patch filenames
5. **Maintain actively**: Update patches when library versions change
6. **Consider upstreaming**: Submit patches upstream when possible
7. **Version independence**: Write patches that survive minor version updates
8. **Focus on integration**: Prioritize CMake exports and build system fixes

## Reference Documentation

- [vcpkg Portfile Functions Reference](https://learn.microsoft.com/vcpkg/maintainers/functions/)
- [vcpkg Maintainer Guide](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide)
- [Git Patch Documentation](https://git-scm.com/docs/git-format-patch)
- [CMake Export Guide](https://cmake.org/cmake/help/latest/guide/importing-exporting/index.html)