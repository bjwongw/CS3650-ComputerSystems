#ifndef DIRECTORY_H
#define DIRECTORY_H

#define DIR_SIZE 64
#define DIR_NAME 48

#include "slist.h"
#include "pages.h"

typedef struct dirent {
    char   name[DIR_NAME];
    int    node_idx;
} dirent;

typedef struct directory {
    int     pnum;
    dirent* ents;
    inode*  node;
} directory;

void directory_init();
directory directory_from_inum(int inum);
int directory_lookup_inum(directory dd, const char* name);
int tree_lookup_inum(const char* path);
directory directory_from_path(const char* path);
int directory_put_ent(directory dd, const char* name, int inum);
int directory_delete_ent(directory dd, const char* name);
int delete_directory(const char* path);
slist* directory_list(const char* path);
void print_directory(directory dd);

#endif

