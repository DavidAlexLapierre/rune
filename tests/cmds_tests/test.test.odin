package cmds_tests

import "core:testing"

import "../mocks"
import "../../src/cmds"
import "../../src/utils"


@(test)
should_process_tests :: proc(t: ^testing.T) {
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

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = "MOCK_PROFILE"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "MOCK_PROFILE",
                build_mode = "exe"
            }
        }
    }

    res := cmds.process_test(sys, { "test" }, schema)
    testing.expect_value(t, res, "")
}

@(test)
should_process_tests_with_test_flag :: proc(t: ^testing.T) {
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

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = "MOCK_PROFILE"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "MOCK_PROFILE",
                build_mode = "exe"
            }
        }
    }

    res := cmds.process_test(sys, { "test", "-t:some_test" }, schema)
    testing.expect_value(t, res, "")
}

@(test)
should_process_tests_with_package_flag :: proc(t: ^testing.T) {
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

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = "MOCK_PROFILE"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "MOCK_PROFILE",
                build_mode = "exe"
            }
        }
    }

    res := cmds.process_test(sys, { "test", "-p:some_package" }, schema)
    testing.expect_value(t, res, "")
}

@(test)
should_process_tests_with_file_flag :: proc(t: ^testing.T) {
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

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = "MOCK_PROFILE"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "MOCK_PROFILE"
            }
        }
    }

    res := cmds.process_test(sys, { "test", "-f:some_file" }, schema)
    testing.expect_value(t, res, "")
}

@(test)
should_process_test_if_not_default :: proc(t: ^testing.T) {
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

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = "MOCK_PROFILE"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "MOCK_PROFILE",
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

    res := cmds.process_test(sys, { "test", "not_default" }, schema)
    testing.expect_value(t, res, "")
}

@(test)
should_fail_if_profile_not_found :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = "MOCK_PROFILE"
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

    res := cmds.process_test(sys, { "test" }, schema)
    defer delete(res)
    testing.expect_value(t, res, "Profile MOCK_PROFILE does not exists")
}

@(test)
should_fail_if_no_default_profile :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = ""
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

    res := cmds.process_test(sys, { "test" }, schema)
    defer delete(res)
    testing.expect_value(t, res, "No default test profile is defined")
}

@(test)
should_fail_if_file_flag_malformed :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = "MOCK_PROFILE"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "MOCK_PROFILE",
                build_mode = "exe"
            }
        }
    }

    res := cmds.process_test(sys, { "test", "-f" }, schema)
    defer delete(res)
    testing.expect_value(t, res, "Invalid file flag -f. Make sure it is formatted -f:<file_name>")
}

@(test)
should_fail_if_test_flag_malformed :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = "MOCK_PROFILE"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "MOCK_PROFILE",
                build_mode = "exe"
            }
        }
    }

    res := cmds.process_test(sys, { "test", "-t" }, schema)
    defer delete(res)
    testing.expect_value(t, res, "Invalid test name flag -t. Make sure it is formatted -t:<test_name>")
}

@(test)
should_fail_if_package_flag_malformed :: proc(t: ^testing.T) {
    sys := utils.System {}

    schema := utils.Schema {
        configs = {
            output = "MOCK_OUTPUT",
            test_output = "MOCK_OUTPUT",
            target = "MOCK_TARGET",
            test_profile = "MOCK_PROFILE"
        },
        profiles = {
            {
                arch = "windows_amd64",
                entry = ".",
                name = "MOCK_PROFILE",
                build_mode = "exe"
            }
        }
    }

    res := cmds.process_test(sys, { "test", "-p" }, schema)
    defer delete(res)
    testing.expect_value(t, res, "Invalid package flag -p. Make sure it is formatted -p:<package_name>")
}