#include <unistd.h>
#include <sys/wait.h>

int real_waitid(idtype_t idtype, id_t id, siginfo_t *infop, int options, void*);

int main()
{
  // allocate memory for buffer for user input
  char command[255];  

  // for-loop to continuously run shell
  for (;;) {
    
    /* 
     * ssize_t write(int fd, const void buf[.count], size_t count);
     * arg `fd` is 1 for stdout
     * arg `buf` is "# " for shell prompt
     * arg `count` is 2 for count of bytes in output buffer ("# ")
     */ 
    write(1, "# ", 2);
   
    /*
     * ssize_t read(int fd, void buf[.count], size_t count);
     * On success, the number of bytes written is returned.  
     * On error, -1 is returned, and errno is set to indicate the error.
     * arg `fd` is 0 for stdin`
     * arg `buf` is `command` for storing user input
     * arg `count` is 255 for size of buffer to store user input (constant 255 bytes)
     * assuming success, store the number of bytes written into `count`
     */
    int count = read(0, command, 255);

    /*
     * User input is newline terminated, we want it null-terminated
     * /bin/ls\n -> /bin/ls\0
     */
    command[count - 1] = 0;

    /*
     * pid_t fork(void);
     * On success, the PID of the child process is returned in the parent, and 0 is returned in 
     * the child.  On failure, -1 is returned in the parent, no child process is created, and 
     * errno is set to indicate the error. 
     */
    pid_t fork_result = fork();
    
    // If we are in the child, execve the command
    if (fork_result == 0) {
      
      /*
       * int execve(const char *pathname, char *const _Nullable argv[],
       * arg `*pathname` is `command` for the command that the user just inputted
       * arg `argv[]` is 0, nulling argument
       * arg `envp[]` is 0, nulling argument
       */
      char *argv[] = { command, NULL };
      char *envp[] = { NULL };
      execve(command, argv, envp);
      
      // Break loop so that child process will not also become a shell
      break;
    } 
    
    // Otherwise, we are in the parent
    else {
      
      /*
       * Wait until the child process completes executing command
       * arg `idtype` is `P_ALL` to wait for any child process, ID ignored
       * arg `id` is 0, we match any child ID
       * arg `*infop` is passed an empty pointer `&info`
       * arg `options` is `WEXITED` so that true is returned if the child is terminated normally
       */
      siginfo_t info;
      real_waitid(P_ALL, 0, &info, WEXITED, 0);

    }
  }
  
  // Invoke exit syscall
  _exit(0);
}
