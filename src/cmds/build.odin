package cmds

import "core:fmt"
import "core:strings"

import "../utils"


// BuildData holds build-specific metadata such as entry file, output path,
// compiler flags, and architecture. This struct can be reused for tasks that 
// need to manage build configuration.
BuildData :: struct {
    entry:  string,             // Entry point file for the build
    output: string,             // Output file path for the built binary
    flags:  [dynamic]string,    // Additional flags to pass to the compiler
    arch:   string,             // Target architecture for the build (e.g., "x86_64")
}

// process_build handles the `rune build [profile?]` command.
//
// It uses the provided `args` to determine which profile to build.
// If no profile is explicitly provided, it uses the default one from the schema.
// The selected profile is then passed to `utils.process_profile` for actual compilation.
//
// Parameters:
// - sys:    The system abstraction used to interact with the OS or shell.
// - args:   Command-line arguments passed to `rune build`.
// - schema: Parsed rune.json configuration containing profiles and settings.
//
// Returns:
// - success: A success message string, if the build completes successfully.
// - err:     An error message string, if something goes wrong.
process_build :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> (success: string, err: string) {
    // If no default profile is set and no profile is passed in args, return an error
    if schema.default_profile == "" && len(args) < 2 {
        err = strings.clone("No default profile was set. Define one or rerun using `rune build [profile]`")
        return "", err
    }

    // Get profile name either from the command-line or fallback to default profile
    profile_name := len(args) > 1 ? args[1] : schema.default_profile

    // Try to retrieve the specified profile from the schema
    profile, profile_ok := utils.get_profile(schema, profile_name)
    if !profile_ok {
        err = fmt.aprintf("Failed to find \"%s\" in the list of profiles", profile_name)
        return "", err
    }

    // Run the actual build process using the retrieved profile
    err = utils.process_profile(sys, profile, schema, args[0])
    if err != "" {
        return "", err
    }

    return strings.clone("Build completed"), ""
}
