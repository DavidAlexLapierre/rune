package cmds

import "core:fmt"
import "core:strings"

import "../utils"


// process_script handles the `rune [script]` command.
//
// It uses the provided `args` to determine which script to run.
// If no script is explicitly provided, it returns an error message.
//
// Parameters:
// - sys:    The system abstraction used to interact with the OS or shell.
// - args:   Command-line arguments passed to `rune build`.
// - schema: Parsed rune.json configuration containing profiles and settings.
//
// Returns:
// - success: A success message string, if the script completes successfully.
// - err:     An error message string, if something goes wrong.
process_script :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> (string, string) {
    // Try to match the argument to a defined script
    script: string
    for key in schema.scripts {
        if key == args[0] {
            script = schema.scripts[key]
            break
        }
    }

    // If no script matched, return an error
    if script == "" {
        return "", fmt.aprintf("Script %s doesn't exists", args[0])
    }

    // Run the script using the utility shell processor
    script_err := utils.execute_script_with_logs(sys, script)

    // If the script had an error, return that
    if script_err != "" {
        return "", script_err
    }

    return strings.clone("Successfully executed script"), ""
}