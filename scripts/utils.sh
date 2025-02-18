infoln() {
    # Print the argument passed to the function in blue
    echo -e "\033[1;34m$*\033[0m"
}

errorln() {
    # Print the argument passed to the function in red
    echo -e "\033[1;31m$*\033[0m"
}