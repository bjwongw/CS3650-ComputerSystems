// Brendon Wong
// CS 3650 - Computer Systems

#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdbool.h>

#define MAX_LINE_SIZE 256
#define MAX_ARG_SIZE 80
#define NORMAL 0
#define OUTPUT_REDIRECT 10
#define INPUT_REDIRECT 20

/**
 * Executes the given commands in the args parameter
 * argc: number of elements in args
 * args: char pointer to char pointers
 * redirect_file: optional argument containing the redirect file
 * redirect_flag: indicates whether to execute normally, or redirect input/output
 * background_flag: specifies whether or not to execute in a background process
 */
void execute(int argc, char* args[], char* redirect_file, int redirect_flag, int background_flag)
{
    if (argc < 1) {
        return;
    }

    char* cmd = args[0];

    // Handle the 'exit' case
    if (strcmp(cmd, "exit") == 0) {
        exit(0);
    }

    // Handle the 'cd' case
    if (strcmp(cmd, "cd") == 0 && argc > 1) {

        // Fetch the directory name 
        char* directory = args[1];

        // Change directories
        chdir(directory);
        return;
    }

    int fd[2];
    int cpid;
    if ((cpid = fork())) {
        if (background_flag == 1) {
            // Do not wait for child to finish
            return;
        }

        int status;
        waitpid(cpid, &status, 0);

        if (WIFEXITED(status)) {
            // Child exited or main returned
        }
    }
    else {
        switch(redirect_flag) {
            case INPUT_REDIRECT:
                fd[0] = open(redirect_file, O_RDONLY);
                dup2(fd[0], STDIN_FILENO);
                close(fd[0]);
                break; 
            case OUTPUT_REDIRECT:
                // 0666: On create, grant RW privileges to owner, group, and others
                fd[0] = open(redirect_file, O_WRONLY | O_CREAT, 0666);
                dup2(fd[0], STDOUT_FILENO);
                close(fd[0]);
                break;
        }

        execvp(cmd, args);
        
        // Should only hit this in an error
        exit(1);
    }
}

/**
 * Copies the elements from the src array starting from the given start index to the 
 * given end index.
 *
 * start: starting index
 * end: ending index
 * size of destination must be at least end+1, as dest[end] will be set to NULL
 */
void get_subarray(char* dest[], char* src[], int start, int end)
{
    if (start >= end) {
        printf("start param must be less than end\n");
        return;
    }

    int endIndex = end - start;
    for (int ii = 0; ii < endIndex; ++ii) {
        dest[ii] = src[start + ii];
    }

    dest[endIndex] = NULL;
}

/**
 * Parses the given command for the following shell operators: <, >, &&, ||, &
 * Executes the commands once they are separated by operators
 */
void parse_operators_and_execute(char* cmd)
{
    // Operators and commands are space delimited
    const char* delimiter = " \n";
    char* token;

    // Get the first token
    token = strtok(cmd, delimiter);

    char* args[MAX_ARG_SIZE];
    args[0] = token;

    // Collect the remaining tokens into an array
    int ii = 0;
    while (token != NULL) {
        token = strtok(NULL, delimiter);
        args[++ii] = token;
    }

    int fd;
    bool matched_op = false;
    int background_flag = 0;

    // Intentionally starting at 1. args[0] should be the command.
    for (int jj = 1; jj < ii; ++jj) {
        int kk = jj + 1;
        if (strcmp(args[jj], "<") == 0 && kk < ii) {
            matched_op = true;

            // jj + 1 to make space for the NULL terminator
            char* cmd[jj + 1];
            get_subarray(cmd, args, 0, jj);
            execute(jj, cmd, args[kk], INPUT_REDIRECT, background_flag);
            break;
        }
        else if (strcmp(args[jj], ">") == 0 && kk < ii) {
            matched_op = true;

            // jj + 1 to make space for the NULL terminator
            char* cmd[jj + 1];
            get_subarray(cmd, args, 0, jj);
            execute(jj, cmd, args[kk], OUTPUT_REDIRECT, background_flag);
            break;
        }
        else if (strcmp(args[jj], "&") == 0) {
            background_flag = 1;
        }
        else if (strcmp(args[jj], "&&") == 0) {
            matched_op = true;
            if (strcmp(args[0], "false") == 0) {
                break;
            } 
            else {
                // Handle the command before &&
                char* cmdBeforeOp[jj + 1];
                get_subarray(cmdBeforeOp, args, 0, jj);

                char* dummy = "";
                execute(jj, cmdBeforeOp, dummy, NORMAL, background_flag);

                // Handle the command after &&
                int numElemAfterOp = ii - kk;
                char* cmdAfterOp[numElemAfterOp + 1];
                get_subarray(cmdAfterOp, args, kk, ii);
                execute(numElemAfterOp, cmdAfterOp, dummy, NORMAL, background_flag);
            }
            break;
        }
        else if (strcmp(args[jj], "||") == 0) {
            matched_op = true;
            if (strcmp(args[0], "false") == 0) {
                // Handle the command after ||
                int numElemAfterOp = ii - kk;
                char* cmdAfterOp[numElemAfterOp + 1];
                get_subarray(cmdAfterOp, args, kk, ii);

                char* dummy = "";
                execute(numElemAfterOp, cmdAfterOp, dummy, NORMAL, background_flag);
            }
            else {
                // Handle the command before ||
                char* cmdBeforeOp[jj + 1];
                get_subarray(cmdBeforeOp, args, 0, jj);

                char* dummy = "";
                execute(jj, cmdBeforeOp, dummy, NORMAL, background_flag);
            }
            break;
        }
    }

    if (!matched_op) {
        char* dummy = "";
        execute(ii, args, dummy, NORMAL, background_flag);
    }
}

/**
 * Parses the given command for semicolons and executes its contents
 */
void parse_and_execute(char* cmd)
{
    // First, parse for semicolons
    const char* semicolon = ";\n";
    char* token;
    char* args[MAX_ARG_SIZE];

    // Get the first token
    int ii = 0;
    token = strtok(cmd, semicolon);
    args[ii++] = token;

    // Collect the remaining tokens into an array
    while (token != NULL) {
        token = strtok(NULL, semicolon);
        args[ii++] = token;
    }

    // Parse for operators and execute
    for (int jj = 0; jj < ii; ++jj) {
        parse_operators_and_execute(args[jj]);
    }
}

/**
 * Reads from stdin or file given as a command line argument and executes
 * their commands
 */
int main(int argc, char* argv[])
{
    FILE* stream;

    if (argc == 1) {
        // Reading from stdin
        printf("nush$ ");
        fflush(stdout);

        stream = stdin;
    }
    else if (argc > 1) {
        // Reading from a file given on the command line
        stream = fopen(argv[1], "r");
    }

    // Declare the char array
    char cmd[MAX_LINE_SIZE];

    // Read each line and execute
    while(fgets(cmd, MAX_LINE_SIZE, stream) != NULL) {
        parse_and_execute(cmd);

        if (argc == 1) {
            printf("nush$ ");
        }
    }

    return 0;
}
