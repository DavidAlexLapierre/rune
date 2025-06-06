#+feature dynamic-literals
package cmds_tests

import "core:testing"

import "../mocks"
import "../../src/cmds"
import "../../src/utils"


@(test)
should_build_default :: proc(t: ^testing.T) {
    sys := utils.System {
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
        fs = {
            close = mocks.mock_file_close_ok,
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true
        }
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

    defer delete(schema.scripts)

    build_success, build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_success)
    testing.expect_value(t, build_err, "")
    testing.expect_value(t, build_success, "Build completed")
}

@(test)
should_build_not_default :: proc(t: ^testing.T) {
    sys := utils.System {
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
        fs = {
            close = mocks.mock_file_close_ok,
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true
        }
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "not_default",
            target = "mock_target"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                build_mode = "exe"
            },
            {
                arch = "windows_amd64",
                entry = ".",
                name = "not_default",
                build_mode = "exe"
            }
        }
    }

    defer delete(schema.scripts)

    build_success, build_err := cmds.process_build(sys, { "build", "not_default" }, schema)
    defer delete(build_success)
    testing.expect_value(t, build_err, "")
    testing.expect_value(t, build_success, "Build completed")
}

@(test)
should_fail_profile_not_found :: proc(t: ^testing.T) {
    sys := utils.System {
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
        fs = {
            make_directory = mocks.mock_make_directory_no_err,
            close = mocks.mock_file_close_ok,
            exists = mocks.mock_exists_true
        }
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "not_default",
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

    defer delete(schema.scripts)

    _, build_err := cmds.process_build(sys, { "build", "not_default" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Failed to find \"not_default\" in the list of profiles")
}

@(test)
should_fail_if_create_directory_fails :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            make_directory = mocks.mock_make_directory_err,
            exists = mocks.mock_exists_false
        }
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
                name = "default"
            }
        }
    }

    defer delete(schema.scripts)

    _, build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Error occurred while trying to create output directory ./mock_output")
}

@(test)
should_fail_if_get_extension_fails :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true
        }
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target"
        },
        profiles = {
            {
                arch = "invalid_arch",
                entry = ".",
                name = "default"
            }
        }
    }

    defer delete(schema.scripts)

    _, build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Failed to get extension for invalid_arch")
}

@(test)
should_run_pre_build_scripts :: proc(t: ^testing.T) {
    sys := utils.System {
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
        fs = {
            make_directory = mocks.mock_make_directory_no_err,
            close = mocks.mock_file_close_ok,
            exists = mocks.mock_exists_true
        }
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
                build_mode = "exe",
                pre_build = {
                    scripts = {
                        "test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_success, build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_success)
    testing.expect_value(t, build_err, "")
    testing.expect_value(t, build_success, "Build completed")
}

@(test)
should_fail_if_invalid_pre_build_script :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true
        }
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
                build_mode = "exe",
                pre_build = {
                    scripts = {
                        "invalid_test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    _, build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Script invalid_test is not defined in rune.json")
}

@(test)
should_fail_if_script_fails :: proc(t: ^testing.T) {
    sys := utils.System {
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_err,
            process_close = mocks.mock_process_close_ok,
        },
        fs = {
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true,
            close = mocks.mock_file_close_ok
        }
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
                build_mode = "exe",
                pre_build = {
                    scripts = {
                        "test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    _, build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Script test failed with Exist")
}

@(test)
should_run_post_build_scripts :: proc(t: ^testing.T) {
    sys := utils.System {
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
        fs = {
            close = mocks.mock_file_close_ok,
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true
        }
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
                build_mode = "exe",
                post_build = {
                    scripts = {
                        "test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_success, build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_success)
    testing.expect_value(t, build_err, "")
    testing.expect_value(t, build_success, "Build completed")
}

@(test)
should_fail_if_invalid_post_build_script :: proc(t: ^testing.T) {
    sys := utils.System {
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
        fs = {
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true,
            close = mocks.mock_file_close_ok,
        }
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
                build_mode = "exe",
                post_build = {
                    scripts = {
                        "invalid_test"
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    _, build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_err)
    testing.expect_value(t, build_err, "Script invalid_test is not defined in rune.json")
}

@(test)
should_copy_files_in_post_build :: proc(t: ^testing.T) {
    sys := utils.System {
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
        fs = {
            close = mocks.mock_file_close_ok,
            make_directory = mocks.mock_make_directory_no_err,
            exists = mocks.mock_exists_true,
            open = mocks.mock_open_ok,
            read_dir = mocks.mock_read_dir_ok,
            copy_file = mocks.mock_copy_file_ok,
            is_dir = mocks.mock_is_dir_true
        }
    }

    schema := utils.Schema{
        configs = {
            output = "mock_output",
            profile = "default",
            target = "mock_target",
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "default",
                build_mode = "exe",
                post_build = {
                    copy = {
                        { from = ".", to = "./test"}
                    }
                }
            }
        },
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    build_success, build_err := cmds.process_build(sys, { "build" }, schema)
    defer delete(build_success)
    testing.expect_value(t, build_err, "")
    testing.expect_value(t, build_success, "Build completed")
}