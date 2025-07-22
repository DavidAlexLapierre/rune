package mocks

import "rune:utils"

cfg_base :: utils.Schema {
	default_profile      = "default",
	default_test_profile = "mock_test_profile",
	profiles = {
		{
			arch = "windows_amd64",
			output = "mock_output",
			target = "mock_target",
			entry = ".",
			name = "default",
			build_mode = "exe",
		},
		{
            arch = "windows_amd64",
            output = "mock_output",
            target = "mock_target",
            entry = ".",
            name = "not_default",
            build_mode = "exe"
        },
        {
            arch = "invalid",
            output = "mock_output",
            target = "mock_target",
            entry = ".",
            name = "invalid_arch",
            build_mode = "exe"
        },
	},
}
