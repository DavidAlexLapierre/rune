#+feature dynamic-literals
package cmds_tests

import "core:testing"

import "../mocks"
import "../../src/cmds"
import "../../src/utils"


@(test)
should_fail_if_no_default_and_no_args :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "",
            target = "mock_target"
        }
    }

    _, run_err := cmds.process_run(sys, { "run" }, schema)
    defer delete(run_err)
    testing.expect(t, run_err == "Run script not found", "Should have failed")
}

@(test)
should_run_if_default :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true,
            close = mocks.mock_file_close_ok,
        },
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                build_mode = "exe"
            }
        }
    }

    run_success, run_err := cmds.process_run(sys, { "run" }, schema)
    defer delete(run_success)
    testing.expect_value(t, run_err, "")
    testing.expect_value(t, run_success, "Build completed")
}

@(test)
should_run_if_not_default :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true,
            close = mocks.mock_file_close_ok,
        },
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "not_default",
                build_mode = "exe"
            }
        }
    }

    run_success, run_err := cmds.process_run(sys, { "run", "not_default" }, schema)
    defer delete(run_success)
    testing.expect_value(t, run_err, "")
    testing.expect_value(t, run_success, "Build completed")
}