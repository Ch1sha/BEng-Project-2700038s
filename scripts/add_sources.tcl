# Set the top-level directory containing your modules
set module_dir "verilog_modules"

# Find all subdirectories (non-recursive)
set subdirs [glob -nocomplain -directory $module_dir *]

# Iterate through each subdirectory
foreach dir $subdirs {
    # Glob for all Verilog files in the current directory
    set verilog_files [glob -nocomplain -directory $dir *.v]
    # If any Verilog files are found, add them to the project
    if {[llength $verilog_files] > 0} {
        foreach file $verilog_files {
            add_files $file
        }
    }
}
