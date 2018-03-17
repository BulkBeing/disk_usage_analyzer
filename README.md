# disk_usage_analyzer
Display disk space usage on Linux machines for a specified directory

#### To reduce the number of unnecessary repetitions of directories, the script prints a directory only if ALL of the below conditions are satisfied:
  1. Size should be greater than zero
  2. Should have a data greater than 1GB excluding the sub directories whose size is greater than 1GB.
  3. Conditions 1 and 2 applies recursively for sub directories.
