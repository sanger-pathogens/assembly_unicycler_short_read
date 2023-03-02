class UnicyclerShortreadCompare {
    /**
     * A comparison function that takes into account the file extension. It:
     * - Ignores certain files in "pipeline_info" output folder.
     * - Only checks existence (not content) of certain files: logs, images, html reports etc.
     * - Compares the content of all other files.
     * This function is designed to be passed as a closure to Compare.dirsConform.
     */
    public static def compare(expected, actual) {
        def pathStr = "$expected"
        // Ignore certain files in 'pipeline_info' folder
        def actual_path = actual.toPath()
        def prefixes_to_ignore = ["execution", "pipeline_dag"]
        if (actual_path.getParent().endsWith('pipeline_info') &&
            prefixes_to_ignore.any {prefix -> actual_path.getFileName().toString().startsWith(prefix)}) {
            return Compare.Result.ACCEPT
        }
        // Check both files exist, or return the right kind of error.
        if (!actual.exists()) {
            return Compare.Result.MISSING
        }
        if (!expected.exists()) {
            return Compare.Result.UNEXPECTED
        }
        // Early return to ignore the contents of these files.
        if (
            pathStr.endsWith(".log") ||
            pathStr.endsWith(".html") ||
            pathStr.endsWith(".pdf") ||
            pathStr.endsWith(".svg")
        ) {
            return Compare.Result.ACCEPT
        }
        // Compare the contents of the files.
        if (expected.text.md5() != actual.text.md5()) {
            return Compare.Result.INCORRECT
        }
        // Accept them if they got through all that.
        return Compare.Result.ACCEPT
    }
}

