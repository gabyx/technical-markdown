# Importing this module brings nushell's built-in `std log` commands into scope
# (`log info`, `log warning`, ...), filtered by `NU_LOG_LEVEL` (default INFO):
#   use lib/common.nu *

use std/log
# Defaults for `std log`. The level and date defaults are required on
# nushell <= 0.103 (the devshell version), whose std/log errors without them;
# newer std versions only need the format override (drops the date prefix).
export-env {
    $env.NU_LOG_LEVEL = ($env.NU_LOG_LEVEL? | default "INFO")
    $env.NU_LOG_FORMAT = ($env.NU_LOG_FORMAT? | default "🌻 %ANSI_START%%LEVEL%%ANSI_STOP% | %MSG%")
    $env.NU_LOG_DATE_FORMAT = ($env.NU_LOG_DATE_FORMAT? | default "%Y-%m-%dT%H:%M:%S%.3f")
}

export def "log error" [message: string] {
    log custom $message $env.NU_LOG_FORMAT (log log-level | get ERROR) --ansi (ansi red_reverse) --level-prefix "ERROR"
}

export def "log warning" [message: string] {
    log custom $message $env.NU_LOG_FORMAT (log log-level | get WARNING) --ansi (ansi yellow_reverse) --level-prefix "WARN"
}

export def "log info" [message: string] {
    log custom $message $env.NU_LOG_FORMAT (log log-level | get INFO) --ansi (ansi cyan_reverse) --level-prefix "INFO"
}

export def "log debug" [message: string] {
    if (debug-enabled) {
        log custom $message $env.NU_LOG_FORMAT (log log-level | get DEBUG) --ansi (ansi magenta_reverse) --level-prefix "DEBUG"
    }
}

export def "die" [msg: string] {
    log error $msg

    exit 1
}

def debug-enabled [] {
    ($env.TECHMD_DEBUG? | default "false" | str downcase) in ["1" "true" "yes" "on"]
}
