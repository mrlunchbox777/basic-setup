cheatsheet() {
  echo "
    ***Cheatsheet***
    
    * basic command line tutorial https://ubuntu.com/tutorials/command-line-for-beginners#1-overview

    **Command Info**
    tldr - get simple info on command
    man - get detailed info on command

    **Backend Commands**
    lsof - find process that has file
    wget|curl - make network request
    tail - display the last part of the file
    head - interactive 
    less - read first part of content
    find - find in directory structure
    ssh - secure shell, for remoting
    kill - terminate a process/job

    **Text manipulation**
    awk - find per line
    sed - edit text with regex
    grep - match regex
    sort - sort thing per line
    uniq - uniq string per line
    cat|bat - prints file
    cut - cut string per line
    echo - prints text
    fmt - formats text to 75 char
    tr - text & replace
    nl - number lines
    egrep - extended grep, using ?, +, {, }, |, (, )
    fgrep - egrep in file
    wc - count lines (-l), words (-w), characters (-c), in file

    **Compilation**
    gcc - compile C & C++
    make - run Makefiles

    **Process Manipulation**
    ps - info on running processes
    top|htop|atop - real-time info on running processes

    **Performance and Telemetry**
    nmon - benchmarking, tuning, admin
    iostat - stats for devices and partitions
    sar - stats on Linux subsystems
    vmstat - hardware telemetry reporting

    **Networking**
    nmap - network mapping
    tcpdump - dump network traffic
    ping - send ICMP request
    mtr - ping/traceroute
    traceroute - prints route to host
    dig - dns lookup
    airmon-ng - monitor wireless devices
    airodump-ng - packet capturing
    iptables - configuration of tables, chains, and rules
    netstat - display network info

    **Debugging**
    strace|dtrace|systemtap - trace processes
    uname - info about current system
    df - filesystem usage
    history - commandline history

    **Personal Recommendations**
    watch - repeat command on interval
    tmux|screen - terminal multiplexer
    <command> & - run command as background job
    jobs - list current jobs
    script - record shell session to file
    vim - text editor (https://vim-adventures.com/)
    xargs - text-based \"foreach\"

    https://github.com/kamranahmedse/developer-roadmap
  "
}
